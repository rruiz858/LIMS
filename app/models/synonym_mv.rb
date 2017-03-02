class SynonymMv < Dsstoxdb
  if Rails.env.test?
    self.table_name = 'synonym_mvs'
  else
    self.table_name = 'synonym_mv'
  end
  self.primary_key = 'id'
  belongs_to :generic_substance, foreign_key: 'fk_generic_substance_id', :primary_key => 'id'
end