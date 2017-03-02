class AddCorIdsArrayToUsers < ActiveRecord::Migration
  def change
    add_column :users, :mentor_ids,:string, array:true, default: []
  end
end
