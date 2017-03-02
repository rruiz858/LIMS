class AddContractToTaskOrders < ActiveRecord::Migration
  def change
    add_reference :task_orders, :contract, index: true 
    add_foreign_key :task_orders, :contracts
  end
end
