class AddShortNameAndContactNameAndContactTitleAndEpaContactNameAndFaxAndEmailAndDateAndTypeToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :short_name, :string
    add_column :vendors, :contact_name, :string
    add_column :vendors, :contact_title, :string
    add_column :vendors, :epa_contact_name, :string
    add_column :vendors, :fax, :string
    add_column :vendors, :email, :string
    add_column :vendors, :date, :string
    add_column :vendors, :type, :string
  end
end
