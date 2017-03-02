class AddIsValidToComits < ActiveRecord::Migration
  def change
    add_column :comits, :is_valid, :boolean
  end
end
