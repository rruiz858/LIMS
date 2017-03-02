require 'test_helper'

class ShipmentsActivitiesControllerTest < ActionController::TestCase

  setup do
    @user = users(:superadmin)
    @vendor1 = vendors(:vendor1)
    @vendor2 = vendors(:vendor2)
    @shipment_file = shipment_files(:one)
    shipment_file = '/files/shipment_files/EPA_3333_3333.xls'
    file = fixture_file_upload(shipment_file, 'application/excel')
    @shipment_file2 = ShipmentFile.create(:id=> 1, :file_url => file, :filename => "EPA_3333_3333.xls", :vendor => @vendor1, :order_number => "8943", :user => @user)

  end
  test "the truth" do
    assert true
  end

  test "Should create an activity record" do
    assert_difference('ShipmentsActivity.count') do
      ShipmentFile.move(@vendor2.id, @shipment_file2.filename)
    end
end

end
