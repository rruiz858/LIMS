require 'test_helper'

class MsdsControllerTest < ActionController::TestCase
  def setup
    @msd = msds(:one)
  end

  test "should get new" do
    login_chemadmin
    get :new
    assert_response :success
  end

  test "should create msd" do
    login_chemadmin
    assert_difference('Msd.count',) do
      CoaSummary.new({bottle_barcode: "TX015880"}).save
      pdf_filename = '/files/TX015880_MSDS.pdf'
      file = fixture_file_upload(pdf_filename, 'application/pdf')
      post :create, msd: {msds_pdfs:[file]}
    end
    assert_redirected_to coas_path
  end

  test "should destroy msd" do
    login_chemadmin
    assert_difference('Msd.count', -1) do
      delete :destroy, id: @msd
    end
    assert_redirected_to coas_path
  end
  test "should create MsdsUpload record" do
    login_chemadmin
    assert_difference('MsdsUpload.count',) do
      pdf_filename = '/files/TX015880_MSDS.pdf'
      file = fixture_file_upload(pdf_filename, 'application/pdf')
      post :create, msd: {msds_pdfs: [file]}
    end
    assert_redirected_to coas_path
  end

  test "should not allow unauthorized user to visit new msds upload page" do
    login_chemcurator
    @request.env['HTTP_REFERER'] = 'http://chemtrack/msds/'
    get :new
    assert_response :redirect
  end










end


