class GenericSubstanceCompound < Dsstoxdb
  self.table_name = 'generic_substance_compounds'
  self.primary_key = 'id'
  belongs_to :generic_substance, foreign_key: 'fk_generic_substance_id'
  belongs_to :compound, foreign_key: 'fk_compound_id'
end