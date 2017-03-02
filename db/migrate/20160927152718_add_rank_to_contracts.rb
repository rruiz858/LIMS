class AddRankToContracts < ActiveRecord::Migration
  def change
    add_column :contracts, :rank, :integer
  end
end
