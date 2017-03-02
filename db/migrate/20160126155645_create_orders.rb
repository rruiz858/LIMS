class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.belongs_to :vendor, index: true, foreign_key: true
      t.belongs_to :task_order, index: true, foreign_key: true
      t.string :concentration
      t.integer :amount
      t.string :amount_unit

      t.timestamps null: false
    end
  end
end
