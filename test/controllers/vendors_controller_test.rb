require 'test_helper'

class VendorsControllerTest < ActionController::TestCase
  setup do
    login_chemadmin
    @vendor = vendors(:vendor1)
    @vendor2 = vendors(:vendor2)
    @vendor.name = 'foo'
    @coa_summary = coa_summaries(:five)
    @shipment_file1 = shipment_files(:one)
    @vendor_path = ENV["DIR_PATH"]
    @hash = {label: "NewLabel", name: "NewName",
             other_details: @vendor.other_details,
             phone1: @vendor.phone1, phone2: @vendor.phone2,
             mta_partner: true}

  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:vendors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create vendor" do
    assert_difference('Vendor.count') do

      post :create, vendor: {label: @hash[:label], name: @hash[:name],
                             other_details: @hash[:other_details],
                             phone1: @hash[:phone1], phone2: @hash[:phone2], mta_partner: @hash[:mta_partner]}
      new_path = @vendor_path + "/#{@hash[:name]}"
      FileUtils.rm_rf(new_path)
    end

    assert_redirected_to vendor_path(assigns(:vendor))
  end

  test "should create a clone from a pre-existing vendor" do
    assert_difference ['Vendor.count', 'Contact.count', 'Address.count'], 1 , "Clone Vendor was not created" do

      post :create, previos_vendor: @vendor.id, vendor: {label: 'New Clone', name: 'NewClone',
                             other_details: @vendor.other_details,
                             phone1: @vendor.phone1, phone2: @vendor.phone2, mta_partner: @vendor.mta_partner}
      new_path = @vendor_path + "/NewClone"
      FileUtils.rm_rf(new_path)
    end
    assert_redirected_to vendor_path(assigns(:vendor))
  end

  test "should get new_clone action" do
    get :new_clone, id: @vendor
    assert_response :success
  end


  test "should get view_files" do
    get :view_files
    assert_response :success
  end

  test "should get jstree data" do
    get :jstree_data, path: @vendor_path, :format => :json
    assert_response :success
    assert_not_nil @response.body
    folder_string = Regexp.union(/ACEA/, /Lamnas/, /agreement-1/, /agreement-1/, /agreement-2/, /task-order-1/) #these are the folders found in the Vendors folder in the fixtures directory
    assert_match folder_string, @response.body.to_s
  end

  test "should open file " do
    @file_path = @vendor_path + '/Acea/agreement-1/task-order-1/Duplicate_Bardcodes_COMIT.xls'
    @controller.stubs(:render).returns("success")
    get :open_file, path: @file_path do
      assert_response :success
      assert_match("Duplicate_Bardcodes_COMIT.xls", @controller.response.headers.to_s)
    end

  end
  test "should show vendor" do
    get :show, id: @vendor
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @vendor
    assert_response :success
    assert_select 'input[type=radio][name=contractButton][checked=checked]', {:count => 1}
  end

  test "should have the mta_partner radio button checked for mta_partner" do
    @mta_partner = vendors(:vendor4)
    get :edit, id: @mta_partner
    assert_response :success
    assert_select 'input[type=radio][name=mTAButton][checked=checked]', {:count => 1}
  end
  test "should update vendor" do
    patch :update, id: @vendor, vendor: {label: "NewLabel", name: "NewName",
                                         other_details: @vendor.other_details,
                                         phone1: @vendor.phone1, phone2: @vendor.phone2,
                                         mta_partner: @hash[:mta_partner]}
    assert_redirected_to vendor_path(assigns(:vendor))
  end


  test "should test the new view_shipments view/routes" do
    get :view_shipments, vendor_id: @vendor.id
    assert_response :success
    count = 0
    @vendor.shipment_files.each do |file|
      count +=file.plate_details.each.count
    end
    assert_equal 3, count
    assert_select "th[id='plate_barcode']", "Plate Barcode"
    assert_select "th", :count => 10
  end

  test "should not show plate if vendor not assigned to shipment_file " do
    #there is one shipment_files assinged to this vendor(vendor 2) therefore we should expect 1 record to exists.
    get :view_shipments, vendor_id: @vendor2.id
    assert_response :success
    shipment = @vendor2.shipment_files.first
    assert_equal 1, shipment.plate_details.each.count
    assert_select "th", :count => 10
  end

end
