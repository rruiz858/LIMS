require 'test_helper'

class ComitsControllerTest < ActionController::TestCase
  fixtures :comits, :users, :bottles
  setup do
    @comit = comits(:one)
    @bottle = bottles(:one)
  end

  test "should get index" do
    login_chemadmin
    get :index
    assert_response :success
    assert_not_nil assigns(:comits)
  end

  test "should get new" do
    login_chemadmin
    get :new
    assert_response :success
  end

  test "unauthorized user should not get new comit view" do
    login_cor
    @request.env['HTTP_REFERER'] = 'http://chemtrack/comits/'
    get :new
    assert_response :redirect
  end

  test "should create comit" do
    login_chemadmin
    excel_filename = '/files/1439912095_short_EPA_report.xls'
    file = fixture_file_upload(excel_filename, 'application/excel')
    assert_difference('Comit.count') do
      post :create, comit: { :file_url => file, filename: @comit.filename, file_kilobytes: @comit.file_kilobytes, file_record_count: @comit.file_record_count,  added_by_user_id: @comit.added_by_user_id, deletes: @comit.deletes, updates: @comit.updates, inserts: @comit.inserts  }
    end
  end

  test "should create bottles from comit" do
    login_chemadmin
    excel_filename = 'files/EPA_create_test.xls'
    file = fixture_file_upload(excel_filename, 'application/excel')
    assert_difference('Bottle.count', 1, "Did not create a bottle") do
      post :create, comit: {:file_url => file}
    end
  end

  test "should update bottles from comit to zero" do
    login_chemadmin
    excel_filename = 'files/EPA_delete_test.xls'
    file = fixture_file_upload(excel_filename, 'application/excel')
    assert_difference('Bottle.count', 0, "Did not update a bottle" ) do
      post :create, comit: {:file_url => file}
    end
    @updated_bottle = Bottle.find_by_barcode("VVVV1")
    assert_equal @updated_bottle.qty_available_mg, 2  #qty_available_mg was updated from 0 to 2(from the excel file)
  end

  test "should update bottles from comit" do
    login_chemadmin
    excel_filename = 'files/EPA_update_test.xls'
    file = fixture_file_upload(excel_filename, 'application/excel')
    assert_difference('Bottle.count', 0, "Did not update a bottle") do
      post :create, comit: {:file_url => file}
    end
  end

  test "should test additional header method" do
    login_chemadmin
    excel_filename = 'files/extra_headers_comit.xls'
    file = fixture_file_upload(excel_filename, 'application/excel')
    assert_difference('Bottle.count', 3, "Did not create bottles") do
      post :create, comit: {:file_url => file}
    end
    assert_redirected_to comits_path, "COMIT importation failed"
    notice = Regexp.union(/The following headers where found in COMIT with no actions taken:/, /freeze_that_count/, /extra_header_1/, /extra_header_2/)
    assert_match notice, flash[:notice]
  end

  test "should test that a file_error is created for a comit file with bad bottles" do
    login_chemadmin
    excel_filename = 'files/errors_comit.xls'
    file = fixture_file_upload(excel_filename, 'application/excel')
    assert_difference('FileError.count', 1, "Bottle Validations did not work") do
      post :create, comit: {:file_url => file}
    end
    assert_redirected_to comits_path
    @comit = Comit.last
    assert_equal false, @comit.is_valid
    assert_match "TX002943", @comit.file_error.error_a
    assert_match "TX77788", @comit.file_error.error_b
  end


end


