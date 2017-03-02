class RenameContractIdToAgreementIdInAgreementDocuments < ActiveRecord::Migration

  def self.up
    rename_column :agreement_documents, :contract_id, :agreement_id
  end

  def self.down
    rename_column :agreement_documents, :agreement_id, :contract_id
  end

end


