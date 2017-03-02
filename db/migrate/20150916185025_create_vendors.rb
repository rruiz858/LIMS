class CreateVendors < ActiveRecord::Migration
  def change
    create_table :vendors do |t|
      t.string :name
      t.string :label
      t.string :phone1
      t.string :phone2
      t.text :other_details

      t.timestamps null: false
    end
  end
end
