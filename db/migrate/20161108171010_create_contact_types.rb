class CreateContactTypes < ActiveRecord::Migration
  def change
    create_table :contact_types do |t|
      t.string :kind

      t.timestamps null: false
    end
  end
end
