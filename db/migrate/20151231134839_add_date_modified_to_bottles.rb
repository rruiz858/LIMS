class AddDateModifiedToBottles < ActiveRecord::Migration
  def change
    add_column :bottles, :date_modified, :string
  end
end
