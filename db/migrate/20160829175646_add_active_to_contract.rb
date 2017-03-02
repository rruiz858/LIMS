class AddActiveToContract < ActiveRecord::Migration
  def change
    add_column :contracts, :active, :boolean, default: 0
  end
end
