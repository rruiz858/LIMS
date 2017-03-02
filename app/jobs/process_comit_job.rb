class ProcessComitJob < ProgressJob::Base
  include TestEnvironment
  include OpenExcel
  include DsstoxSchema

  def initialize(comit)
    super progress_max: comit.bottle_count
    @comit = comit
    if test_environment
      perform
    end
  end

  def perform
    unless test_environment
      update_stage('Validating bottles')
    end
    validate = Bottle.new.validate_duplicate_barcodes(@comit)
    @error_string = ""
    if validate[:valid]
      begin
      #This is done to obtain the count of bottles that were depleted.
      non_zero_bottles = Bottle.find_by_sql("SELECT barcode, stripped_barcode, qty_available_mg, qty_available_ul, qty_available_mg_ul FROM bottles WHERE (qty_available_mg_ul IS NOT NULL AND qty_available_mg_ul > 0);")
      comit_bottles = validate[:comit_bottles]
      comit_bottles.each do |bottle|
        update_progress_bar
        b = Bottle.find_or_initialize_by(barcode: bottle[:barcode])
        b.assign_attributes(bottle)
        b.save(:validate => false)
      end
      rescue => @error_string
        unless @error_string.blank?
          raise ActiveRecord::Rollback, "Internal Error occured with background job"
        end
      end
      timestamp = Bottle.order("updated_at").last.updated_at.utc
      update_counts(@comit, timestamp, non_zero_bottles)
      map_bottles_to_coas
    else
      @comit.update_attributes(is_valid: 0, processing: 0)
      @comit.build_file_error(error_a: validate[:error_a], error_b: validate[:error_b], error_count: validate[:error_count]).save
    end
  end

  def update_counts(comit, timestamp, non_zero_bottles)
    @updated_bottles = Bottle.find_by_sql("SELECT COUNT(*) as count FROM bottles AS b WHERE (b.created_at < '#{timestamp}' AND b.updated_at = '#{timestamp}') ;").first.try(:count)
    @created_bottles = Bottle.find_by_sql("SELECT COUNT(*) as count FROM bottles AS b WHERE (b.created_at = '#{timestamp}') ;").first.try(:count)
    update_qty_fields
    zero_bottles= Bottle.find_by_sql("SELECT barcode, stripped_barcode, qty_available_mg, qty_available_ul, qty_available_mg_ul FROM bottles WHERE (qty_available_mg_ul IS NULL or qty_available_mg_ul = 0);")
    @depleted_bottles = non_zero_bottles.map{|i| i[:stripped_barcode]} & zero_bottles.map{|z| z[:stripped_barcode]} # this gets the intersection of bottles that were depleted during a COMIT upload
    comit.update_attributes(is_valid: 1, inserts: @created_bottles, updates: @updated_bottles, deletes: @depleted_bottles.count, processing: 0)
  end

  def update_qty_fields #This method called is to updated the correct qty_fields for bottles with mg/ul as well as the units column
    schema = database_initialization
    connection = ActiveRecord::Base.connection
    connection.execute(" UPDATE bottles as b
    Inner join bottles as b2
    on b.id = b2.id
    SET b.qty_available_mg_ul = b2.qty_available_ul, b.units = 'ul'
    WHERE b.qty_available_ul IS NOT NULL AND b.qty_available_mg IS NULL;")
    connection.execute(" UPDATE bottles as b
    Inner join bottles as b2
    on b.id = b2.id
    SET b.qty_available_mg_ul = b2.qty_available_mg, b.units = 'mg'
    WHERE b.qty_available_mg IS NOT NULL AND b.qty_available_ul IS NULL;")
  end

  def map_bottles_to_coas
    CoaSummaryFile.coa_summary_bottle_mapping
  end

  def error(job, exception)
    @comit = Comit.find(job.job_id)
    @comit.update_attributes(is_valid: 0, processing: 0)
    @comit.build_file_error(error_a: exception, error_b: exception).save
  end

end

