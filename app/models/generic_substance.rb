class GenericSubstance < Dsstoxdb
  self.table_name = 'generic_substances'
  self.primary_key = 'id'
  has_one :source_generic_substance, foreign_key: 'fk_generic_substance_id'
  has_many :coa_summaries, foreign_key: 'gsid'
  has_many :bottles, through: :coa_summaries
  has_many :generic_substance_compounds, foreign_key: 'fk_generic_substance_id'
  has_many :compounds, :through => :generic_substance_compounds
  has_many :synonym_mvs, foreign_key: 'fk_generic_substance_id'

  def self.gsid_found(gsid)
   query = self.find_by_id(gsid)
   query.blank? ? false : query.id
  end

end
