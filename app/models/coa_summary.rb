class CoaSummary < ActiveRecord::Base
  include OpenExcel
  has_many :bottles, dependent: :destroy
  has_one :coa, dependent: :destroy
  has_one :msd, dependent: :destroy
  belongs_to :user
  belongs_to :source_substance, foreign_key: 'source_substance_id'
  belongs_to :chemical_list, foreign_key: 'chemical_list_id'
  belongs_to :generic_substance, foreign_key: 'gsid'
  validates :gsid, presence: true, on: :update
  validate :validate_record
  scope :uncurated, -> {where('gsid IS NULL')}
  scope :curated, -> {where('gsid IS NOT NULL')}

  def validate_record
    if Bottle.where('stripped_barcode LIKE ?', "%#{bottle_barcode}%").blank?
      errors.add(:bottle_barcode, " '#{bottle_barcode }' was not found in the Bottles database")
    end
  end


  def self.get_gsid(coa_summary)
    schema_hash = CoaSummary.database_initialization
    if coa_summary.coa_casrn.blank?
    casrn = coa_summary.bottles.first.cas
    else
    casrn = coa_summary.coa_casrn
    end
    if coa_summary.coa_chemical_name.blank?
    name = coa_summary.bottles.first.compound_name
    else
    name = coa_summary.coa_chemical_name
    end
    @results = ActiveRecord::Base.connection.select_all( "SELECT gs.id, gs.casrn, gs.preferred_name, gs.qc_level, gs.source FROM #{schema_hash[:gs]} as gs
    INNER JOIN coa_summaries AS coa
    ON coa.coa_casrn = gs.casrn
    WHERE coa.coa_casrn = '#{casrn}'
    UNION
    SELECT gs.id, gs.casrn, gs.preferred_name, gs.qc_level, gs.source FROM #{schema_hash[:gs]} as gs
    INNER JOIN coa_summaries AS coa
    ON gs.preferred_name LIKE '%#{name}%'
    WHERE coa.coa_chemical_name = '#{name}'
    UNION
    SELECT gs.id, gs.casrn, gs.preferred_name, gs.qc_level, gs.source FROM #{schema_hash[:gs]} as gs
    INNER JOIN bottles AS b
    ON b.cas = gs.casrn
    WHERE b.coa_summary_id = #{coa_summary.id}
    UNION
    SELECT gs.id, gs.casrn, gs.preferred_name, gs.qc_level, gs.source FROM #{schema_hash[:gs]} as gs
    INNER JOIN bottles AS b
    ON gs.preferred_name LIKE '%#{name}%'
    WHERE b.coa_summary_id = #{coa_summary.id}
    ;")
    return @results
  end



  def self.database_initialization
    if Rails.env.test?
      schema_hash = {:ss => "source_substances", :ssi => "source_substance_identifiers", :sgm => "source_generic_substances", :gs => "generic_substances" }
      return schema_hash
    elsif Rails.env.development?
      schema_hash = {:ss => "sbox_dsstox_rruizvev.source_substances", :ssi => "sbox_dsstox_rruizvev.source_substance_identifiers", :sgm => "sbox_dsstox_rruizvev.source_generic_substance_mappings", :gs => "sbox_dsstox_rruizvev.generic_substances" }
      return schema_hash
    elsif Rails.env.production?
      schema_hash = {:ss => "sbox_dsstox.source_substances", :ssi => "sbox_dsstox.source_substance_identifiers", :sgm => "sbox_dsstox.source_generic_substance_mappings", :gs => "sbox_dsstox.generic_substances" }
      return schema_hash
    end
  end

  def validate_coa_summaries(coa_summary_file, user)
    #This checks for duplicate coas in the excel file
    #Also it checks for if a coa is new, but then already is in CoaSummary table
    #Also checks if coa summary's bottle barcode is in Bottle barcode
    coa_barcodes = CoaSummary.find_by_sql("SELECT bottle_barcode FROM coa_summaries;")
    bottle_inventory = Bottle.find_by_sql("SELECT stripped_barcode FROM bottles;")
    existing_coas = Array.new
    existing_bottles = Array.new
    for coa_summary in coa_barcodes.each
      existing_coas.push(coa_summary.bottle_barcode)
    end
    for bottle in bottle_inventory.each
      existing_bottles.push(bottle.stripped_barcode)
    end
    spreadsheet = open_spreadsheet(coa_summary_file.file_url.path)
    header = spreadsheet.row(1)
    array_of_hashes =  all_coa_summaries(user, spreadsheet, header)
    file_coas = []
    for i in 0...array_of_hashes.length
      file_coas << (array_of_hashes[i][:bottle_barcode].to_s)
    end
    @error_results = find_errors(file_coas, existing_coas, existing_bottles)
    if !(@error_results[:total_error_str].blank?)
     {:valid => false, :error_a => @error_results[:duplicate_coas],
      :error_b => @error_results[:new_duplicates], :error_c => @error_results[:no_bottle_match],
      :error_count => @error_results[:total_count]}
    else
     {:valid => true, :coa_summaries => array_of_hashes}
    end
  end

  def all_coa_summaries(user, spreadsheet, header)
    coa_summary_array = Array.new
    config = Rails.configuration.database_configuration
    database = config[Rails.env]["database"]
    chemical_list = ChemicalList.where(list_name: "#{database}_COA_Summary_Chemical_List").order("id DESC").first
    (2..spreadsheet.last_row).each do |j|
      row = Hash[[header, spreadsheet.row(j)].transpose]
      @coa_summaries = {:bottle_barcode => row['Bottle Barcode'],
                        :coa_product_no => row['COA_Product_No'],
                        :coa_lot_number => row['COA_Lot Number'],
                        :coa_chemical_name => row['COA_ChemicalName'],
                        :coa_casrn => row['COA_CASRN'],
                        :coa_molecular_weight => row['COA_MolecularWeight'],
                        :coa_density => row['COA_Denstity'],
                        :coa_purity_percentage => row['COA_Purity_(%)'],
                        :coa_methods => row['COA_Methods'],
                        :coa_test_date => row['CoA Test Date'],
                        :coa_expiration_date => row['CoA Expiration Date'],
                        :msds_cautions => row['MSDS_Cautions'],
                        :user_id => user.id,
                        :chemical_list_id => chemical_list.id}
      coa_summary_array << @coa_summaries
    end
    coa_summary_array
  end

  def find_errors(file_coas, existing_coas, existing_bottles)
    duplicate_coas_str = ""
    new_duplicate_coas_str = ""
    no_bottles_match_str = ""
    duplicate_coas = file_coas.select { |e| file_coas.count(e) >1 }.uniq #duplicates within file
    new_duplicates = existing_coas & file_coas  #intersection between two arrays. If coas intersect, then there will be an error since every coa should be unique
    no_bottle_match =  file_coas - existing_bottles # if subtraction produces array values, that means some coa summaries do not have bottles in the inverntory
    total_error_count = (duplicate_coas.count + new_duplicates.count + no_bottle_match.count)
    for barcode in duplicate_coas.each
      duplicate_coas_str += barcode + "\n"
    end
    for barcode in new_duplicates.each
      new_duplicate_coas_str += barcode + "\n"
    end
    for barcode in no_bottle_match.each
      no_bottles_match_str += barcode + "\n"
    end
    total_error_str = duplicate_coas_str + new_duplicate_coas_str + no_bottles_match_str
    {duplicate_coas: duplicate_coas_str,
     new_duplicates: new_duplicate_coas_str,
     no_bottle_match: no_bottles_match_str,
     total_error_str: total_error_str,
     total_count: total_error_count}
  end


  def direct_bottle_match
    Bottle.find_by_stripped_barcode(self.bottle_barcode)
  end

end