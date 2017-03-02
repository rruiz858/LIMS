class CreateFileErrors < ActiveRecord::Migration
  CREATE_TIMESTAMP = 'DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP'
  UPDATE_TIMESTAMP = 'DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'
  def change
    create_table :file_errors do |t|
      t.text :error_a
      t.text :error_b
      t.integer :error_count
      t.references :errorable, polymorphic: true, index: true
      t.column :created_at, CREATE_TIMESTAMP
      t.column :updated_at, UPDATE_TIMESTAMP
      t.index :updated_at
    end
  end
end
