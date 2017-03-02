class CreateOrderDsstoxChemicalLists < ActiveRecord::Migration
  def change
    create_table :order_dsstox_chemical_lists do |t|
      t.belongs_to :order, index: true, foreign_key: true
      t.integer :dsstox_chemical_list_id, index: true
      t.timestamps null: false
    end
  end
end
