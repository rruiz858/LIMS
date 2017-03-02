class CreateOrderConcentration < ActiveRecord::Migration
  def change
    create_table :order_concentrations do |t|
      t.integer :concentration
      t.string :unit
    end
  end
end
