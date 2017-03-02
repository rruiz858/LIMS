class AddCanPlateToBottle < ActiveRecord::Migration
  def change
    add_column :bottles, :can_plate, :boolean, default: true
  end
end
