class AddOrderNumberToShipmentsActivity < ActiveRecord::Migration
  def change
    add_column :shipments_activities, :order_number, :string

  end
end
