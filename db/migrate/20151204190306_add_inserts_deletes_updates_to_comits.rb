class AddInsertsDeletesUpdatesToComits < ActiveRecord::Migration
  def change
    add_column :comits, :inserts, :integer
    add_column :comits, :deletes, :integer
    add_column :comits, :updates, :integer
  end
end
