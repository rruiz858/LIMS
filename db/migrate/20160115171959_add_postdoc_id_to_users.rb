class AddPostdocIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :cor_ids, :integer
  end
end
