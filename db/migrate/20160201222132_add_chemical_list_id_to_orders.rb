class AddChemicalListIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :chemical_list_id, :integer
  end
end
