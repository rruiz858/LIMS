class AddNameAndDecriptionToTaskOrders < ActiveRecord::Migration
  def change
    add_column :task_orders, :name, :string
    add_column :task_orders, :description, :text
  end
end
