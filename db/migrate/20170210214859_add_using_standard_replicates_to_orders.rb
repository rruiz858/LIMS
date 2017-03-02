class AddUsingStandardReplicatesToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :using_standard_replicates, :boolean, :default => false
  end
end
