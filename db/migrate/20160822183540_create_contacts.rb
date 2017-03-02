class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :first_name
      t.string :last_name
      t.belongs_to :vendor, index: true, foreign_key: true
      t.string :email
      t.string :title
      t.string :phone1
      t.string :phone2
      t.string :fax
      t.string :cell
      t.text :other_details

      t.timestamps null: false
    end
  end
end
