class CreateQueries < ActiveRecord::Migration
  def change
    create_table :queries do |t|
      t.string :name
      t.string :label
      t.text :description
      t.string :created_by
      t.string :sql

      t.timestamps null: false
    end
  end
end
