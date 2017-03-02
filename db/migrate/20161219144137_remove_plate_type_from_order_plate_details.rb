class RemovePlateTypeFromOrderPlateDetails < ActiveRecord::Migration
  def up
    remove_column :order_plate_details, :plate_type
  end

  def down
    add_column :order_plate_details, :plate_type, :string
  end

end
