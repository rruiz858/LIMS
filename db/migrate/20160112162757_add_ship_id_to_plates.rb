class AddShipIdToPlates < ActiveRecord::Migration
  def change
    add_column :plates, :ship_id, :string
  end
end
