class AddRankToTaskOrders < ActiveRecord::Migration
  def change
    add_column :task_orders, :rank, :integer
  end
end
