class AddQtyAvailableMgUlAndUnitsToBottle < ActiveRecord::Migration
  def change
    add_column :bottles, :qty_available_mg_ul, :integer
    add_column :bottles, :units, :string
  end
end
