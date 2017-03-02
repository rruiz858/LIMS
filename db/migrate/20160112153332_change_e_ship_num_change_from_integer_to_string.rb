class ChangeEShipNumChangeFromIntegerToString < ActiveRecord::Migration
  def change
    change_column :shipment_files, :e_ship_num_change, :string
  end
end
