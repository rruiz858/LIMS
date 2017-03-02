class RemoveUnwantedColumnsFromUsers < ActiveRecord::Migration
  def change
    remove_columns :users, :cor_ids, :roles_mask
  end
end
