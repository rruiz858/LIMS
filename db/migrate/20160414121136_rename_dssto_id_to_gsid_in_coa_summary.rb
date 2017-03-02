class RenameDsstoIdToGsidInCoaSummary < ActiveRecord::Migration
  def change
    rename_column :coa_summaries, :dssto_id, :gsid
  end
end
