class CreateContracts < ActiveRecord::Migration
  CREATE_TIMESTAMP = 'DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP'
  UPDATE_TIMESTAMP = 'DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'
  def change
    create_table :contracts do |t|
      t.string :name
      t.belongs_to :contract_status, index: true, foreign_key: true
      t.belongs_to :vendor, index: true, foreign_key: true
      t.text :description
      t.column :created_at, CREATE_TIMESTAMP
      t.column :updated_at, UPDATE_TIMESTAMP
      t.index :updated_at
    end
  end
end
