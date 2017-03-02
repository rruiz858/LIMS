class AddDriedDownToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :dried_down, :boolean, default: false
  end
end
