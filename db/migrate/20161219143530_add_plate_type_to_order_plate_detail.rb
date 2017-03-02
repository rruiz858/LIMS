class AddPlateTypeToOrderPlateDetail < ActiveRecord::Migration
  def change
    add_reference :order_plate_details, :plate_type, index: true, foreign_key: true
  end
end
