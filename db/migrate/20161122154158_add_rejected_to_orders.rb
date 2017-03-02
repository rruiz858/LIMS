class AddRejectedToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :rejected, :boolean, :default => false
  end
end
