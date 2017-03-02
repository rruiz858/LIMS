class AddShipAddress1AndShipAddress2AndCountryToAddresses < ActiveRecord::Migration
  def change
    add_column :addresses, :ship_address_1, :string
    add_column :addresses, :ship_address_2, :string
    add_column :addresses, :country, :string
  end
end
