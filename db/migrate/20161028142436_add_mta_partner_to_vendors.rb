class AddMtaPartnerToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :mta_partner, :boolean
  end
end
