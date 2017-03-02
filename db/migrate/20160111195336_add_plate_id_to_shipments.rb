class AddPlateIdToShipments < ActiveRecord::Migration
  def change
    add_reference :shipments, :plate, index: true, foreign_key: true
  end
end
