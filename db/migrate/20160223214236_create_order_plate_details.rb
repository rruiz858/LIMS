class CreateOrderPlateDetails < ActiveRecord::Migration
  def change
    create_table :order_plate_details do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.belongs_to :order, index: true, foreign_key: true
      t.string :plate_type
      t.text :empty
      t.text :solvent
      t.text :control

      t.timestamps null: false
    end
  end
end
