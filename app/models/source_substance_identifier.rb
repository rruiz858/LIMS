class SourceSubstanceIdentifier< Dsstoxdb
  self.table_name = 'source_substance_identifiers'
  self.primary_key = 'id'
  belongs_to :source_substance, foreign_key: 'fk_source_substance_id', :primary_key => 'id'
end