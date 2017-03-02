class AddSolubilityToBottles < ActiveRecord::Migration
  def change
    rename_column :bottles, :solubility_dmso, :solubility
    rename_column :bottles, :solubitity_details, :solubility_details
    add_column :bottles, :solubility_solvent, :string
  end
end
