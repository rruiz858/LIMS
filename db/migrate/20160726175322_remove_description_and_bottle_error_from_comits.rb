class RemoveDescriptionAndBottleErrorFromComits < ActiveRecord::Migration
  def up
    remove_columns :comits, :description, :bottle_error
  end
  def down
    add_column :comits, description, :text
    add_column :comits, bottle_error, :integer
  end
end
