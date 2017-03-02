class Compound < Dsstoxdb
  self.table_name = 'compounds'
  self.primary_key = 'id'
  has_many :generic_substance_compounds, foreign_key: 'fk_compound_id'
  has_many :generic_substances, :through => :generic_substance_compounds
end