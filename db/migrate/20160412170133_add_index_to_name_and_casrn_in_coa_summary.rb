class AddIndexToNameAndCasrnInCoaSummary < ActiveRecord::Migration
  def change
    add_index :coa_summaries, :coa_chemical_name
    add_index :coa_summaries, :coa_casrn
  end
end
