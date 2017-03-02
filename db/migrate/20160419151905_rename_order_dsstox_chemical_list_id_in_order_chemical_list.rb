class RenameOrderDsstoxChemicalListIdInOrderChemicalList < ActiveRecord::Migration
  def change
    rename_column :order_chemical_lists, :dsstox_chemical_list_id, :chemical_list_id
  end
end
