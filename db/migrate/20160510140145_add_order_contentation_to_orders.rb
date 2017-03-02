class AddOrderContentationToOrders < ActiveRecord::Migration
  def change
    add_reference :orders, :order_concentration, index: true, foreign_key: true
  end
end
