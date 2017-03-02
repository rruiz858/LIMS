class AddBottleCountToComits < ActiveRecord::Migration
  def change
    add_column :comits, :bottle_count, :integer
  end
end
