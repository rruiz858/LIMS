class RemoveShipAddress1AndShipAddress2FromAddresses < ActiveRecord::Migration
  def change
    remove_columns :addresses, :ship_address_1, :ship_address_2
  end
end
