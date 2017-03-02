class AddCommentToShipmentFile < ActiveRecord::Migration
  def change
    add_column :shipment_files, :comment, :text
  end
end
