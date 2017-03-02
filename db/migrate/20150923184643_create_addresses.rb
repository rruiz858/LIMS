class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :address1
      t.string :address2
      t.string :city
      t.string :state
      t.string :zip
      t.text :other_details
      t.references :vendor, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
