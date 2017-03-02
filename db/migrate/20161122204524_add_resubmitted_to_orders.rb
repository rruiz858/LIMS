class AddResubmittedToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :resubmitted, :boolean, :default => false
  end
end
