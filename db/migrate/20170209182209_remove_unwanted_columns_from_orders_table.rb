class RemoveUnwantedColumnsFromOrdersTable < ActiveRecord::Migration
  def up
    remove_column :orders, :concentration
    remove_column :orders, :amount_unit
  end

  def down
    add_column :orders, :concentration, :integer
    add_column :orders, :amount_unit, :integer
  end
end

