module ShipmentsActivitiesHelper
  def find_vendor(vendor)
    Vendor.find_by_name(vendor)
  end
end
