class RenameOrderDsstoxChemicalListToOrderChemicalList < ActiveRecord::Migration
  def self.up
    rename_table :order_dsstox_chemical_lists, :order_chemical_lists
  end

  def self.down
    rename_table :order_chemical_lists, :order_dsstox_chemical_lists
  end
end

