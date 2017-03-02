require 'test_helper'

class ShipmentFileTest < ActiveSupport::TestCase
  setup do
    extend ActionDispatch::TestProcess
    @coa_summary = coa_summaries(:one)
    @bottle = bottles(:one)
    @vendor1 = vendors(:vendor1)
    @vendor2 = vendors(:vendor2)
    @user = users(:superadmin)
    @shipment_file = shipment_files(:one)
  end


  test "should allow the saving of a CSV file" do
    csv = '/files/shipment_files/EPA_60606_10101.csv'
    file = fixture_file_upload(csv, 'text/comma-separated-values')
    shipment_file = ShipmentFile.new(:file_url => file, :vendor => @vendor1, :order_number => "54343")
    assert_nil shipment_file.errors.messages[:file_url], "This file has errors when it shouldn't have any"
    assert shipment_file.save
  end

  test "should allow the saving of a xlsx file" do
    xlsx = '/files/shipment_files/EPA_60606_10101.xlsx'
    file = fixture_file_upload(xlsx, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    shipment_file = ShipmentFile.new(:file_url => file, :vendor => @vendor1, :order_number => "54343")
    assert_nil shipment_file.errors.messages[:file_url], "This file has errors when it shouldn't have any"
    assert shipment_file.save
  end


  test "should validate the format of the name of a file" do
    excel_filename = 'files/shipment_files/WRONG_EPA_1111_1111.xls'
    file = fixture_file_upload(excel_filename, 'application/excel')
    shipment_file = ShipmentFile.new(:file_url => file, :vendor => @vendor1, :order_number => "32432")
    assert_not shipment_file.save
    assert_match "Shipment File should be formated in the following format: EPA_#####_#####.csv|xls|xlsx", shipment_file.errors.messages[:original_filename].to_s
  end

  test "validate correct amounts of columns and headers" do
    excel_filename = '/files/shipment_files/EPA_4444_4444.xls'
    file = fixture_file_upload(excel_filename, 'application/excel')
    shipment_file = ShipmentFile.new(:file_url => file, :vendor => @vendor1, :order_number => "43980")
    assert_nil shipment_file.errors.messages[:file_url], "This file does not have any errors when it should"
    assert_not shipment_file.save
  end

  test "should can save a blank comment on an update" do
    path = '/files/shipment_files/EPA_3333_3333.xls'
    file = fixture_file_upload(path, 'application/excel')
    shipment_file = ShipmentFile.create(:file_url => file, :vendor => @vendor1, :order_number => "7980890")
    shipment_file.update_attributes(comment: "")
    assert_nil shipment_file.errors.messages[:comment]
    assert shipment_file.save
  end

  test "should not save file if both the order_number and the order_id are both present or if they are both missing " do
    path = '/files/shipment_files/EPA_3333_3333.xls'
    file = fixture_file_upload(path, 'application/excel')
    shipment_file = ShipmentFile.create(:file_url => file, :vendor => @vendor1, :order_number => @shipment_file.order_number, :order_id => @shipment_file.order_id )
    shipment_file_2 = ShipmentFile.create(:file_url => file, :vendor => @vendor1, :order_number => "", :order_id => "" )
    assert_not_nil shipment_file.errors.messages[:base]
    assert_not_nil shipment_file_2.errors.messages[:base]
    assert_not shipment_file.save
    assert_not shipment_file_2.save
  end


  test "should test external and raw_shipment scopes " do
    path = '/files/shipment_files/EPA_3333_3333.xls'
    file = fixture_file_upload(path, 'application/excel')
    shipment_file_raw = ShipmentFile.create(:file_url => file, :vendor => @vendor1, :order_number => "7980890", external: 0)
    assert_includes(ShipmentFile.raw_shipments, shipment_file_raw)
  end


  test "Should update the bottle_id field" do
    excel_filename = '/files/shipment_files/EPA_3333_3333.xls'
    file = fixture_file_upload(excel_filename, 'application/excel')
    ShipmentFile.create(:file_url => file, :vendor => @vendor1, :order_number => "8943", :user => @user)
    plate = PlateDetail.last
    assert_not_nil plate.bottle_id do
      assert :success
    end
  end

end