class SourceGenericSubstance < Dsstoxdb
  if Rails.env.test?
    self.table_name = 'source_generic_substances'
  else
    self.table_name = 'source_generic_substance_mappings'
  end
  self.primary_key = 'id'
  belongs_to :source_substance, foreign_key: 'fk_source_substance_id'
  belongs_to :generic_substance, foreign_key: 'fk_generic_substance_id'
end