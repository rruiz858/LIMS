class AddCreatedByToContracts < ActiveRecord::Migration
  def change
    add_column :contracts, :created_by, :string
  end
end
