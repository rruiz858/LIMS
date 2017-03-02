class AddUpdatedByToContracts < ActiveRecord::Migration
  def change
    add_column :contracts, :updated_by, :string
  end
end