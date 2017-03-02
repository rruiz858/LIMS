class AddCreatedByToTaskOrders < ActiveRecord::Migration
  def change
    add_column :task_orders, :created_by, :string
  end
end
