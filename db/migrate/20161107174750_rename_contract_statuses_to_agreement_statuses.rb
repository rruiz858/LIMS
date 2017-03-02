class RenameContractStatusesToAgreementStatuses < ActiveRecord::Migration

  def self.up
    rename_table :contract_statuses, :agreement_statuses
  end

  def self.down
    rename_table :agreement_statuses, :contract_statuses
  end

end
