class AddRevokeReasonToContract < ActiveRecord::Migration
  def change
    add_column :contracts, :revoke_reason, :text
  end
end
