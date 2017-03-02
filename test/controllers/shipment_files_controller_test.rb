require 'test_helper'

class ShipmentFilesControllerTest < ActionController::TestCase
  setup do
    @shipment_file = shipment_files(:one)
    @external_shipment = shipment_files(:external_shipment)
    @user = users(:superadmin)
    @vendor1 = vendors(:vendor1)
    @vendor2 = vendors(:vendor2)
    @task_order = task_orders(:two)
    @address = addresses(:arapaho)
    @plate_detail = plate_details(:one)
    @order_concentration = order_concentrations(:two)
    @update = {
        comment: 'I love my mom'
    }
    @coa_summary = coa_summaries(:three)
    @bottle = bottles(:nine)
    shipment_file = '/files/shipment_files/EPA_3333_3333.xls'
    file = fixture_file_upload(shipment_file, 'application/excel')
    @shipment_file2 = ShipmentFile.create!(:file_url => file,
                                          :vendor => @vendor1,
                                          :order_number => "8943",
                                          :user => @user)
  end

  test "should get index" do
    login_chemadmin
    get :index
    assert_response :success
    assert_not_nil assigns(:shipment_files)
    assert_select "#shipment-file-#{@shipment_file.id}", "Legacy-Archived"
  end

  test "should get new with Vendor and Order ID fields" do
    login_chemadmin
    get :new
    assert_response :success
    assert_select '.control-group .control-group', "Vendor"
    assert_select '.control-group .control-group', "Order ID"
  end

  test "should create shipment_file" do
    login_chemadmin
    shipment_file = '/files/shipment_files/EPA_60606_10101.xls'
    file = fixture_file_upload(shipment_file, 'application/excel')
    assert_difference('ShipmentFile.count') do
      post :create, shipment_file: {file_kilobytes: @shipment_file.file_kilobytes,
                                    :file_url => file,
                                    filename: @shipment_file.filename,
                                    user_id: @shipment_file.user_id,
                                    vendor_id: @shipment_file.vendor_id,
                                    order_number: "898908" }
    end
    assert_redirected_to shipment_files_url
  end
  test "should create mixture shipment_file" do
    login_chemadmin
    shipment_file = '/files/shipment_files/EPA_1830950_1085050.xls'
    file = fixture_file_upload(shipment_file, 'application/excel')
    assert_difference('ShipmentFile.count') do
      post :create, shipment_file: {file_kilobytes: @shipment_file.file_kilobytes,
                                    :file_url => file,
                                    filename: @shipment_file.filename,
                                    user_id: @shipment_file.user_id,
                                    vendor_id: @shipment_file.vendor_id,
                                    order_number: "89432",
                                    mixture: 1}
    end
    assert_redirected_to shipment_files_url
  end


  test "should add the correct evotech order and plate_detail numbers during a create" do
    login_chemadmin
    shipment_file = '/files/shipment_files/EPA_60606_10101.xls'
    file = fixture_file_upload(shipment_file, 'application/excel')
    assert_difference('ShipmentFile.count') do
      post :create, shipment_file: {file_kilobytes: @shipment_file.file_kilobytes, :file_url => file, filename: @shipment_file.filename, user_id: @shipment_file.user_id, vendor_id: @shipment_file.vendor_id, order_number: "898908"}
    end
    assert_match ShipmentFile.last.evotech_order_num, "60606"
    assert_match ShipmentFile.last.evotech_shipment_num, "10101"
  end

  test "should determine an uploaded file is a vial shipment and create vial detail records" do
    login_chemadmin
    vial_shipment_file = '/files/shipment_files/EPA_1919_1818.xls'
    vial_file = fixture_file_upload(vial_shipment_file, 'application/excel')
    assert_difference('VialDetail.count', 1, "No Vial Detail was inserted") do
      post :create, shipment_file: {file_kilobytes: @shipment_file.file_kilobytes,
                                    :file_url => vial_file,
                                    filename: @shipment_file.filename,
                                    user_id: @shipment_file.user_id,
                                    vendor_id: @shipment_file.vendor_id,
                                    order_number: "898908"}

    end
  end

  test "should test the creation of shipment_file if leading zero needs to be added to records" do
    login_chemadmin
    shipment_file = '/files/shipment_files/EPA_6854454_43432.xls'
    file = fixture_file_upload(shipment_file, 'application/excel')
    assert_difference('ShipmentFile.count') do
      post :create, shipment_file: {file_kilobytes: @shipment_file.file_kilobytes, :file_url => file, filename: @shipment_file.filename, user_id: @shipment_file.user_id, vendor_id: @shipment_file.vendor_id, order_number: "898908"}
    end
    assert_response :redirect
    assert_redirected_to shipment_files_url
    assert_match /The Following EPA_Sample_ids required a leading zero for mapping:/, flash[:notice]
    assert_match /TP00013736565B04/, flash[:notice]
  end

  test "should show shipment_file and correct amounts of table headers and cell elements  " do
    login_chemadmin
    get :show, id: @shipment_file2
    assert_response :success
    assert_select "th", :count => 19
    @shipment_file2.destroy
  end

  test "should have blinded and unblinded buttons " do
    login_chemadmin
    @shipment1 = PlateDetail.create(:bottle => @bottle, :shipment_file => @shipment_file2)
    get :show, id: @shipment_file2
    assert_template 'shipment_files/show'
    assert_select "a[id='blinded']", "Blinded"
    assert_select "a[id= 'unblinded']", "Unblinded"
    @shipment_file2.destroy

  end

  test "should update comment,vendor location  and order number in shipment_file" do
    login_chemadmin
    patch :update, id: @shipment_file2, shipment_file: {comment: "Ilovemom", vendor: @vendor2, order_number: "68909"}
    assert_redirected_to shipment_file_path(assigns(:shipment_file))
    @shipment_file2.destroy
  end

  test "should display show page with update button " do
    login_chemadmin
    get :show, id: @shipment_file2
    assert_template 'shipment_files/show'
    assert_select "a[id='Update']", "Update"
    @shipment_file2.destroy
  end

  test "should destroy shipment_file" do
    login_chemadmin
    assert_difference('ShipmentFile.count', -1) do
      delete :destroy, id: @shipment_file
    end

    assert_redirected_to shipment_files_path
  end

  test "should create a new external shipment file" do
    login_chemadmin
    assert_difference("ShipmentFile.count") do
    post :create_external_shipment, {add_shipment: "Add Bottles", vendor_id: @vendor2.id, task_order_id: @task_order.id, address_id: @address.id, order_concentration_id: @order_concentration.id,
                                  amount: 30, amount_unit: "ul", plate_detail: 96}
    end
    get :add_bottles, id: ShipmentFile.last.id
    assert_response :success
  end

  test "should add Bottles to external shipment file and makes sure that the well ID is generated" do
    login_chemadmin
    assert_difference("ShipmentsBottle.count") do
    post :add_bottles, id: @external_shipment.id, add_barcodes: "Add Barcodes", barcodes: "llamas",  format: :js
    end
    @well_id = ShipmentsBottle.last.well_id
    assert_equal "A1", @well_id
  end

  test "should finalize shipment file" do
    login_chemadmin
    post :finalize_plate, id: @external_shipment.id, finalize_shipment: "Finalize"
    assert_redirected_to shipment_files_path
  end

  test "should edit a shipments_bottle record in the show_plate view" do
    login_chemadmin
    get :show_plate, id: @external_shipment
    @record = ShipmentsBottle.last
    assert_response :success
    post :edit_record,  shipment_file_id: @external_shipment.id, record_id: @record.id, update_record: "Update",  format: :js
  end

  test "Test that Cor can only see the shipments sent to a vendor that they are asigned to" do
    login_cor
    get :index
    assert_response :success
    assert_not_nil assigns(:shipment_files)
    assert_select "tr", 3
  end

  test "Test that Postdoc can only see the shipments sent to a vendor that are assigned to their Cor" do
    login_postdoc
    get :index
    assert_response :success
    assert_not_nil assigns(:shipment_files)
    assert_select "tr", 6
  end

  test "should ensure the number of plates is equal to 3" do
    login_chemadmin
    get :index, id: @shipment_file
    assert_response :success
    assert_select "td#plates_#{@shipment_file.id}", {text: "3"}
  end

  test "should ensure the sample id is a 'Plate'" do
    login_chemadmin
    get :index, id: @shipment_file
    assert_response :success
    assert_select "td#samples_#{@shipment_file.id}", {text: "Plate"}
  end

  test "should ensure plate maps are properly sorted" do
    login_chemadmin
    get :show, id: @plate_detail
    assert_select "td#plate-barc-#{@plate_detail.id}", {text: "Alpha"}
  end
end
