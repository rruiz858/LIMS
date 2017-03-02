class RenameContractIdToAgreementIdInTaskOrders < ActiveRecord::Migration

  def self.up
    rename_column :task_orders, :contract_id, :agreement_id
  end

  def self.down
    rename_column :task_orders, :agreement_id, :contract_id
  end

end
