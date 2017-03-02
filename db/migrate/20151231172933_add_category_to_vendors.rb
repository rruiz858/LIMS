class AddCategoryToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :category, :string
  end
end
