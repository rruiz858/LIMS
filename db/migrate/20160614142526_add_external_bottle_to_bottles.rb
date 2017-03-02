class AddExternalBottleToBottles < ActiveRecord::Migration
  def change
    add_column :bottles, :external_bottle, :boolean, default: false
  end
end
