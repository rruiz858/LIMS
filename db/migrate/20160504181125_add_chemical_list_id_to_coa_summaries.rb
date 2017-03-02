class AddChemicalListIdToCoaSummaries < ActiveRecord::Migration
  def change
    add_column :coa_summaries, :chemical_list_id, :integer
  end
end
