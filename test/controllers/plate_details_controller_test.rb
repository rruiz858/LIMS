require 'test_helper'

class PlateDetailsControllerTest < ActionController::TestCase
  setup do
    @vendor1 = vendors(:vendor1)
    @coa_summary = coa_summaries(:three)
    @bottle = bottles(:nine)
    @plate_detail = plate_details(:one)
    @shipment_file = shipment_files(:one)
    @vial_shipment = shipment_files(:vial)
    @vial_detail = vial_details(:one)
    @shipment_file_no_plates = shipment_files(:two)
    @plate_detail4 = plate_details(:four)
    @vial_detail2 = vial_details(:two)
  end


  test "should show plate_detail record" do
    login_chemadmin
    get :show, id: @plate_detail, shipment_file_id: @shipment_file
    assert_response :success
  end


  test "should test the blinded action for excel file" do
    login_chemadmin
    evotec_shipment_number = @shipment_file.evotech_shipment_num
    number_of_details = @shipment_file.plate_details.count
    vendor = @vendor1.name
    date = Time.now.strftime('%Y%m%d')
    filename= "EPA_#{evotec_shipment_number}_#{vendor}_#{number_of_details}_#{date}.xls"
    get :blinded, id: @plate_detail, shipment_file_id: @shipment_file
    assert_response :success
    assert_match(filename, @controller.response.headers.to_s)
    assert_operator @response.body.size, :>, 0
    assert_equal 'application/vnd.ms-excel', @response.headers['Content-Type']
  end

  test "should test the correct median target concentration of 100 ul if no order is present" do
    login_chemadmin
    shipment_file = '/files/shipment_files/EPA_3333_3333.xls'
    file = fixture_file_upload(shipment_file, 'application/excel')
    @shipment_file_2 = ShipmentFile.create(:file_url => file,
                                           :vendor => @vendor1,
                                           :order_number => 8943,
                                           :user => @user,
                                           :evotech_order_num => 3333,
                                           :evotech_shipment_num => 3333)
    ShipmentFile::DetailExport.new(shipment_file: @shipment_file_2.id).insert_details_transaction
    @plate_detail_2 = @shipment_file_2.plate_details.first
    get :blinded, id: @plate_detail_2.id, shipment_file_id: @shipment_file_2.id
    assert_operator @response.body.size, :>, 0
    assert_equal 'application/vnd.ms-excel', @response.headers['Content-Type']
  end

  test "cor can open their own blinded and unblided files" do
    login_cor
    @request.env['HTTP_REFERER'] = 'http://chemtrack/activities'
    get :blinded, id: @plate_detail, shipment_file_id: @shipment_file
    assert_response :success
    assert_operator @response.body.size, :>, 0
    assert_equal 'application/vnd.ms-excel', @response.headers['Content-Type']
  end


  test "should test the unblinded action for excel file" do
    login_chemadmin
    evotec_shipment_number = @shipment_file.evotech_shipment_num
    number_of_details = @shipment_file.plate_details.count
    vendor = @vendor1.name
    date = Time.now.strftime('%Y%m%d')
    filename= "EPA_#{evotec_shipment_number}_#{vendor}_#{number_of_details}_#{date}_key.xls"
    get :unblinded, id: @plate_detail, shipment_file_id: @shipment_file
    assert_response :success
    assert_operator @response.body.size, :>, 0
    assert_equal 'application/vnd.ms-excel', @response.headers['Content-Type']
    assert_match(filename, @response.headers.to_s)
  end

  test "should get show vial details" do
    login_chemadmin
    get :show_vial, shipment_file_id: @vial_shipment.id, vial_detail_id: @vial_detail.id
    assert_response :success
  end

  test "should test blinded_vial action" do
    login_chemadmin
    get :blinded_vial, id: @vial_detail.id, shipment_file_id: @vial_shipment.id do
      @controller.stubs(:render).returns("success")
      assert_match /blinded_file.xls/, @response.headers.to_s
      assert_equal @response.headers['Content-Type'], 'application/vnd.ms-excel'
    end
  end

  test "should test unblinded_vial action" do
    login_chemadmin
    evotec_shipment_number = @shipment_file.evotech_shipment_num
    number_of_details = @shipment_file.plate_details.count
    date = Time.now.strftime('%Y%m%d')
    filename= "EPA_#{evotec_shipment_number}_#{number_of_details}_#{date}_key.xls"
    get :unblinded_vial, id: @vial_detail.id, shipment_file_id: @vial_shipment.id do
      assert_match(filename, @response.headers.to_s)
      assert_response :success
      assert_equal @response.headers['Content-Type'], 'application/vnd.ms-excel'
      assert_operator @response.body.size, :>, 0
    end
  end

  test "should test redirect if no plate detials for file" do
    login_chemadmin
    get :unblinded, shipment_file_id: @shipment_file_no_plates.id do
      assert_response :redirect
      assert_equal "This action is not available at this time", flash[:notice]
    end
  end
end
