class AddIndexToBottles < ActiveRecord::Migration
  def change
    add_index :bottles, :stripped_barcode, unique: true
  end
end
