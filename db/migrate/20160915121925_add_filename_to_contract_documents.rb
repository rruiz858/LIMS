class AddFilenameToContractDocuments < ActiveRecord::Migration
  def change
    add_column :contract_documents, :filename, :string
  end
end
