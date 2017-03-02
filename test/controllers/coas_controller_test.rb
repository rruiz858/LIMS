require 'test_helper'

class CoasControllerTest < ActionController::TestCase
  setup do
    @coa = coas(:one)
    CoaSummary.new({bottle_barcode: "TX015880"}).save
  end

  test "should get index" do
    login_chemadmin
    get :index
    assert_response :success
    assert_not_nil assigns(:coas)
  end

  test "should create coa file" do
    login_chemadmin
    assert_difference('CoaUpload.count',) do
      pdf_filename = '/files/TX015880_COA.pdf'
      file = fixture_file_upload(pdf_filename, 'application/pdf')
      post :create, coa: {coa_pdfs: [file]}
    end
  end
  test "should not allow unauthorized user to visit new coa upload page" do
    login_chemcurator
    @request.env['HTTP_REFERER'] = 'http://chemtrack/coas/'
    get :new
    assert_response :redirect
  end

  test "should get new" do
    login_chemadmin
    get :new
    assert_response :success
  end

  test "should create coa" do
    login_chemadmin
    assert_difference('Coa.count',) do
      pdf_filename = '/files/TX015880_COA.pdf'
      file = fixture_file_upload(pdf_filename, 'application/pdf')
      post :create, coa: {coa_pdfs: [file]}
    end
  end

  test "should destroy coa" do
    login_chemadmin
    assert_difference('Coa.count', -1) do
      delete :destroy, id: @coa
    end

    assert_redirected_to coas_path
  end
end
