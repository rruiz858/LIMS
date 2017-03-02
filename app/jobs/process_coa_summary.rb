class ProcessCoaSummary < ProgressJob::Base
  include TestEnvironment
  include OpenExcel
  include SourceSubstanceGenericMapping
  include DsstoxSchema

  def initialize(coa_summary_file)
    super progress_max: coa_summary_file.coa_summary_count
    @coa_summary_file = coa_summary_file
    if test_environment
      perform
    end
  end

  def perform
    unless test_environment
      update_stage('Inserting Coa Summaries')
    end
    @user = @coa_summary_file.user
    validate = CoaSummary.new.validate_coa_summaries(@coa_summary_file, @user)
    if validate[:valid]
      coa_summary_ids = Array.new
      records_array = validate[:coa_summaries]
      @error_str = ''
      records_array.each do |summary|
        update_progress_bar
        coa = CoaSummary.find_or_initialize_by(bottle_barcode: summary[:bottle_barcode])
        coa.assign_attributes(summary)
        coa.save
        coa_summary_ids.push(coa.id)
      end
      Dsstoxdb.transaction do
        begin
          coa_generic_substance(coa_summary_ids, @user)
        rescue => e
          @error_str << e.to_s
        end
      end
      if @error_str.blank?
        @coa_summary_file.update_attributes(is_valid: 1, description: "Successfully uploaded file")
      else
        CoaSummary.where("id IN (?)", coa_summary_ids).destroy_all
        @coa_summary_file.update_attributes(is_valid: 0, description: @error_str)
        @coa_summary_file.build_file_error(error_a: @error_str, error_b: @error_str, error_c: @error_str).save
      end
    else
      @coa_summary_file.update_attributes(is_valid: 0, description: validate[:error], record_error: validate[:error_count])
      @coa_summary_file.build_file_error(error_a: validate[:error_a], error_b: validate[:error_b], error_c: validate[:error_c], error_count: validate[:error_count]).save
    end
  end

  def coa_generic_substance(coa_summary_ids, user)
    CoaSummaryFile.create_dsstox_mapping(coa_summary_ids, user)
    config = Rails.configuration.database_configuration
    database = config[Rails.env]["database"]
    chemical_list = ChemicalList.where("list_name LIKE ?", "%#{database}_COA_Summary_Chemical_List%").first
    schema = database_initialization
    @source_substances = SourceSubstance.find_by_sql("SELECT ss.id FROM #{schema[:ss]} AS ss WHERE ss.id NOT IN( SELECT sgm.fk_source_substance_id FROM
              #{schema[:sgm]} as sgm) AND ss.fk_chemical_list_id = #{chemical_list.id} ;")
    source_generic_mapping(@source_substances, user.username)
  end

  def error(job, exception)
    @coa_summary_file = CoaSummaryFile.find(job.job_id)
    @coa_summary_file.update_attributes(is_valid: 0)
    @coa_summary_file.build_file_error(error_a: exception, error_b: exception, error_c: exception).save
  end

end

