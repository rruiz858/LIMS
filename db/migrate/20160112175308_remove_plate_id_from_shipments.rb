class RemovePlateIdFromShipments < ActiveRecord::Migration
  def change
    remove_foreign_key(:shipments, :plate)
  end
end
