class RenameContractsToAgreements < ActiveRecord::Migration

  def self.up
    rename_table :contracts, :agreements
  end

  def self.down
    rename_table :agreements, :contracts
  end

end
