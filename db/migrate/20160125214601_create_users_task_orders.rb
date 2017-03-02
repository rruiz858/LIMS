class CreateUsersTaskOrders < ActiveRecord::Migration
  def change
    create_table :users_task_orders do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.belongs_to :task_order

      t.timestamps null: false
    end
  end
end
