class AddStepNumberToOrderStatus < ActiveRecord::Migration
  def change
    add_column :order_statuses, :step_number, :integer
  end
end
