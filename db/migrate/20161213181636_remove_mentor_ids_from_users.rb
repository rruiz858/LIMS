class RemoveMentorIdsFromUsers < ActiveRecord::Migration

  def up
    remove_column :users, :mentor_ids
  end

  def down
    add_column :users, :mentor_ids, :string, array: true, default: []
  end

end
