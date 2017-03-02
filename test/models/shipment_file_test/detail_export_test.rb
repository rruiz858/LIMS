require 'test_helper'

class DetailExportTest <  ActiveSupport::TestCase

  setup do
    extend ActionDispatch::TestProcess
    shipment_file = '/files/shipment_files/EPA_3333_3333.xls'
    file = fixture_file_upload(shipment_file, 'application/excel')
    @user = users(:superadmin)
    @vendor1 = vendors(:vendor1)
    @shipment_file1 = ShipmentFile.create!(:file_url => file,
                                           :vendor => @vendor1,
                                           :order_number => "8943",
                                           :user => @user)
  end

  test "validate barcodes in file exists" do
    export = ShipmentFile::DetailExport.new(shipment_file: @shipment_file1.id).insert_details_transaction
    assert_nil export[:errors], "This file has errors when it shouldn't have any"
  end

  test "validate barcodes in file that do not exist" do
    excel_filename = '/files/shipment_files/EPA_5555_5555.xls'
    file = fixture_file_upload(excel_filename, 'application/excel')
    shipment_file = ShipmentFile.create(:file_url => file, :vendor => @vendor1, :order_number => "89789", :user => @user)
    assert_difference('ShipmentFile.count', -1, "Shipment File was not deleted successfully") do
      export = ShipmentFile::DetailExport.new(shipment_file: shipment_file.id).insert_details_transaction
      invalid_barcodes = Regexp.union(/These Barcodes do not exist or are not curated/, /no/, /no/, /no/)
      assert_not_nil export[:errors], "This file does not have errors when it should"
      assert_match invalid_barcodes, export[:errors].to_s, "The expected error does not match the actual errors for invalid barcodes"
    end
  end

  test "should not save a file if concentration and volume units are not valid and should display correct error message " do
    path = '/files/shipment_files/EPA_5555_5555.xls'
    file = fixture_file_upload(path, 'application/excel')
    shipment_file = ShipmentFile.create(:file_url => file, :vendor => @vendor1, :order_number => "438294032", :user => @user)
    assert_difference('ShipmentFile.count', -1, "Shipment File was not deleted successfully") do
      export = ShipmentFile::DetailExport.new(shipment_file: shipment_file.id).insert_details_transaction
      error_string = Regexp.union(/The following units are not allowed/, /mom/, /dad/)
      assert_not_nil export[:errors], "This file does not have errors when it should"
      assert_match error_string, export[:errors].to_s, "Error message regarding incorrect units is not working properly"
    end
  end

  test "Should create a plate_detail record from an shipment file import " do #Upload PlateDetail File, finds a bottle id from bottle fixture, and updates the bottle id in plate_detail record
    excel_filename = '/files/shipment_files/EPA_3333_3333.xls'
    file = fixture_file_upload(excel_filename, 'application/excel')
    assert_difference('PlateDetail.count', 1, "Did not create a PlateDetail record") do
      ShipmentFile::DetailExport.new(shipment_file: @shipment_file1.id).insert_details_transaction
    end
  end

  test "Should create a vial_detail record from an shipment file import " do #Upload PlateDetail File, finds a bottle id from bottle fixture, and updates the bottle id in plate_detail record
    vial_shipment = '/files/shipment_files/EPA_1919_1818.xls'
    file = fixture_file_upload(vial_shipment, 'application/excel')
    assert_difference('VialDetail.count', 1, "Did not create a PlateDetail record") do
      shipment_file = ShipmentFile.create(:file_url => file, :vendor => @vendor1, :order_number => "8943", :user => @user)
      ShipmentFile::DetailExport.new(shipment_file: shipment_file.id).insert_details_transaction
    end
  end

  test "should make sure that a blinded sample id in a vial detail shipment is generated correctly" do
    vial_shipment = '/files/shipment_files/EPA_1919_1818.xls'
    file = fixture_file_upload(vial_shipment, 'application/excel')
    assert_difference('VialDetail.count', 1, "Did not create a PlateDetail record") do
      shipment_file = ShipmentFile.create(:file_url => file, :vendor => @vendor1, :order_number => "8943", :user => @user)
      export = ShipmentFile::DetailExport.new(shipment_file: shipment_file.id).insert_details_transaction
      assert_nil export[:errors], "This file has errors when it shouldn't"
      assert_match /EP18775_1444844/, VialDetail.last.blinded_sample_id, "Blinded sample id was not the cocat. of the plate barcode and the vial_barcode"
    end
  end

  test "Should Create a Blinded Sample ID From Plate and Well IDs for plate details" do
    export = ShipmentFile::DetailExport.new(shipment_file: @shipment_file1.id).insert_details_transaction
    assert_nil export[:errors], "This file has errors when it shouldn't"
    blinded_sample_id = PlateDetail.last.blinded_sample_id
    assert_equal "TP0001373B04", blinded_sample_id , "The Blinded sample id for a plate detail was generated incorrectly"
  end


  test "Should check for the uniquess of blinded sample ids prior to an upload" do
    mixture_shipment= '/files/shipment_files/EPA_183095089_108505089.xls'
    file = fixture_file_upload(mixture_shipment, 'application/excel')
    shipment_file = ShipmentFile.create(:file_url => file, :vendor => @vendor1, :order_number => "8943", :user => @user, mixture: 1)
    assert_difference('ShipmentFile.count', -1, "Shipment File was not deleted successfully") do
      export = ShipmentFile::DetailExport.new(shipment_file: shipment_file.id).insert_details_transaction
      error_message = Regexp.union(/These Blinded Sample Ids are not unique:/, / EPA_Order89NA/, / EPA_Order89NA/, / EPA_Order89NA/, / EPA_Order89NA/)
      assert_not_nil export[:errors], "This file does not have errors when it should"
      assert_match error_message, export[:errors].to_s, "Error message regarding incorrect Blinded Sample Ids is not working properly"
    end
  end

  test "should test that shipment file can not be uploaded if all three cells are empty for barcodes" do
    excel_filename = '/files/shipment_files/EPA_33354543_33354543.xls'
    file = fixture_file_upload(excel_filename, 'application/excel')
    @shipment_file = ShipmentFile.create(:file_url => file, :vendor => @vendor1, :order_number => "8943", :user => @user)
    assert_difference('ShipmentFile.count', -1, "Shipment File was not deleted successfully") do
      export = ShipmentFile::DetailExport.new(shipment_file: @shipment_file.id).insert_details_transaction
      error_message = Regexp.union(/Number of rows without any barcodes:/, /1/)
      assert_not_nil export[:errors], "This file does not have errors when it should"
      assert_match error_message, export[:errors].to_s, "Error message regarding all barcode fields being empty is not working properly"
    end
  end

  test "should test that shipment file can be uploaded if barcode is found after adding a zero to attribute" do
    excel_filename = '/files/shipment_files/EPA_6854454_43432.xls'
    file = fixture_file_upload(excel_filename, 'application/excel')
    assert_difference('ShipmentFile.count', 1, "Shipment File was not deleted successfully") do
      @shipment_file = ShipmentFile.create(:file_url => file, :vendor => @vendor1, :order_number => "8943", :user => @user)
      export = ShipmentFile::DetailExport.new(shipment_file: @shipment_file.id).insert_details_transaction
      assert_not_nil export[:mapped_other].to_json, "The application did not find the correct mapping after concatinating a source barcode"
      mapped_other = export[:mapped_other]
      notice_str = ""
      for detail in mapped_other
        notice_str += detail.blinded_sample_id + "\n"
      end
      assert_match /TP00013736565B04/, notice_str, "Method did not indicate that source barcodes mapped to another bottle after adding leading zero"
    end
  end


end