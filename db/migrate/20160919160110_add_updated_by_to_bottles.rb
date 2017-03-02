class AddUpdatedByToBottles < ActiveRecord::Migration
  def change
    add_column :bottles, :updated_by, :string
  end
end
