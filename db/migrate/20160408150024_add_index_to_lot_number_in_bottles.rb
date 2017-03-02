class AddIndexToLotNumberInBottles < ActiveRecord::Migration
  def change
    add_index :bottles, :lot_number
  end
end
