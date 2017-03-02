require 'test_helper'

class PlateDetailTest < ActiveSupport::TestCase
  setup do
    extend ActionDispatch::TestProcess
    @shipment_file = shipment_files(:one)
  end

  test "should create plate details from a mixture shipment_file" do
    shipment_file = '/files/shipment_files/EPA_1830950_1085050.xls'
    file = fixture_file_upload(shipment_file, 'application/excel')
    assert_difference('PlateDetail.count', 4, 'Plate Details were not created from mixture shipment creation ') do
     mixture_shipment = ShipmentFile.create(file_kilobytes: @shipment_file.file_kilobytes,
                          :file_url => file,
                          user_id: @shipment_file.user_id,
                          vendor_id: @shipment_file.vendor_id,
                          order_number: "89432",
                          mixture: 1)
      @export = ShipmentFile::DetailExport.new(shipment_file: mixture_shipment.id).insert_details_transaction
      assert_nil @export[:error]
      assert @export[:valid]
    end
  end
end
