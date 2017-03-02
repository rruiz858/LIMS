class CreateTaskOrders < ActiveRecord::Migration
  def change
    create_table :task_orders do |t|
      t.belongs_to :vendor, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
