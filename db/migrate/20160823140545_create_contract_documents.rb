class CreateContractDocuments < ActiveRecord::Migration
  CREATE_TIMESTAMP = 'DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP'
  UPDATE_TIMESTAMP = 'DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'
  def change
    create_table :contract_documents do |t|
      t.belongs_to :contract, index: true, foreign_key: true
      t.integer :file_size
      t.string :file_name
      t.string :created_by
      t.string :file_url
      t.column :created_at, CREATE_TIMESTAMP
      t.column :updated_at, UPDATE_TIMESTAMP
    end
  end
end
