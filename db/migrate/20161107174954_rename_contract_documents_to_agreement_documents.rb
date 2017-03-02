class RenameContractDocumentsToAgreementDocuments < ActiveRecord::Migration

  def self.up
    rename_table :contract_documents, :agreement_documents
  end

  def self.down
    rename_table :agreement_documents, :contract_documents
  end

end
