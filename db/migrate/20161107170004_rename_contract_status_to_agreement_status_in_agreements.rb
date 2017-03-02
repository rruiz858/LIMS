class RenameContractStatusToAgreementStatusInAgreements < ActiveRecord::Migration

  def self.up
    rename_column :agreements, :contract_status_id, :agreement_status_id
  end

  def self.down
    rename_column :agreements, :agreement_status_id, :contract_status_id
  end

end

