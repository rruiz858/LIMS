class AddBottleErrorsToComits < ActiveRecord::Migration
  def change
    add_column :comits, :bottle_error, :integer
  end
end
