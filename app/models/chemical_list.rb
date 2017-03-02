class ChemicalList < Dsstoxdb
  include DsstoxSchema
  self.table_name = 'chemical_lists'
  self.primary_key = 'id'
  has_many :source_substances, dependent: :destroy, foreign_key: 'fk_chemical_list_id'
  has_many :coa_summary, dependent: :destroy, foreign_key: 'chemical_list_id'
  has_one :order_chemical_list, dependent: :destroy, foreign_key: 'chemical_list_id'
  has_one :source_generic_substance, dependent: :destroy, foreign_key: 'fk_generic_substance_id'



  def control_chemical_list
    list = ChemicalList.where(list_name: 'ChemTrack Standard Controls')[0]
    list.blank? ? create_chemical_list : list
  end


  def create_chemical_list
    @schema_hash = database_initialization
    @connection = ActiveRecord::Base.connection
    list = ChemicalList.new(list_abbreviation: "CT-Standard-Replicates", list_name: "ChemTrack Standard Controls",
                            list_description:"These chemicals are used for ChemTrack's ordering system",
                            ncct_contact: "Ann Richard", source_contact: "Ann Richard",
                            source_contact_email: "richard.ann@epa.gov", list_type: "LOCAL",
                            list_update_mechanism: "MANUAL", list_accessibility: "EPA",
                            curation_complete: true, source_data_updated_at: "#{Time.now}",
                            created_by: "rruizvev", updated_by: "rruizvev",
                            created_at: "#{Time.now}", updated_at: "#{Time.now}")
    list.save
  end

end