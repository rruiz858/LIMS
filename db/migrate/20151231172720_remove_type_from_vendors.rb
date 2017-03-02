class RemoveTypeFromVendors < ActiveRecord::Migration
  def change
    remove_column :vendors, :type
  end
end
