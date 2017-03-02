module ApplicationHelper
  def track_shipment_activity(trackable, location_a, user, order_number)
    ShipmentsActivity.create( user: user, action: "Moved", location_a: location_a , location_b: trackable.vendor.name ,trackable: trackable, order_number: order_number)
  end

  def human_boolean(boolean)
    boolean ? 'Yes' : 'No'
  end

end
