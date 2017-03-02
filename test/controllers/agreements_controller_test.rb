require 'test_helper'
require 'wicked_pdf'

class AgreementsControllerTest < ActionController::TestCase
  setup do
    login_contract_admin
    @vendor1 = vendors(:vendor1)
    @agreement = agreements(:one)
    @status = agreement_statuses(:two)
    @user = users(:chemadmin)
    @vendor_path = ENV["DIR_PATH"]
    @hash = {name: "NewName", description: "Hi mom",
             vendor: @vendor1.id,
             user: @user.id,
             vendor_name: @vendor1.name }
  end

  test "should get new" do
    get :new, vendor_id: @vendor1
    assert_response :success
  end

  test "should create agreement" do
    assert_difference('Agreement.count') do
      post :create, vendor_id: @vendor1, id: @agreement,
           agreement: {name: @hash[:name], description: @hash[:description], vendor_id: @hash[:vendor], user_id: @hash[:user]}
      new_path = @vendor_path + "/#{@hash[:vendor_name]}"
      FileUtils.rm_rf(new_path)
    end
    assert_redirected_to vendor_path(assigns(:vendor))
  end


  test "should get edit" do
    get :edit, id: @agreement, vendor_id: @vendor1
    assert_response :success
  end

  test "should update agreement" do
    @request.env['HTTP_REFERER'] = 'http://chemtrack/vendors'
    patch :update, vendor_id: @vendor1, id: @agreement,
          agreement: {name: @agreement.name, description: @agreement.description, vendor_id: @vendor1.id, user_id: @user.id}
    assert_response :redirect
  end

  test "should create an activity record if a agreement is updated to a new status" do
    @request.env['HTTP_REFERER'] = 'http://chemtrack/vendors'
    assert_difference('Activity.count') do
      patch :update, vendor_id: @vendor1, id: @agreement,
            agreement: {name: @agreement.name, description: @agreement.description, vendor_id: @vendor1.id, status_id: @status.id, user_id: @user.id}
    end
  end
  test "should get manage_agreements " do
    get :manage_agreements, id: @agreement, vendor_id: @vendor1
    assert_response :success
  end

  test "should add document" do
    assert_difference('AgreementDocument.count') do
      pdf_filename = '/files/TX015880_COA.pdf'
      file = fixture_file_upload(pdf_filename, 'application/pdf')
      post :add_documents, id: @agreement, vendor_id: @vendor1, agreement: {file_url: file, id: @agreement.id}
    end
  end

  test "should create activity record " do
    assert_difference('Activity.count') do
      pdf_filename = '/files/TX015880_COA.pdf'
      file = fixture_file_upload(pdf_filename, 'application/pdf')
      post :add_documents, id: @agreement, vendor_id: @vendor1, agreement: {file_url: file, id: @agreement.id}
    end
  end

  test "should destroy agreement" do
    assert_difference('Agreement.count', -1) do
      delete :destroy, id: @agreement, vendor_id: @vendor1
    end
    assert_redirected_to vendor_path(assigns(:vendor))
  end

  test "should test finalize_agreement action" do
    @complete_status = agreement_statuses(:four)
    post :finalize_agreement, id: @agreement, vendor_id: @vendor1, agreement: {agreement_id: @agreement.id, vendor_id: @vendor1.id, active: 1, agreement_status_id: @complete_status.id}
    @agreement= Agreement.find(@agreement.id)
    assert_equal true, @agreement.active, "Finalize Action did not update active attribute from false to true"
    assert_redirected_to vendor_path(assigns(:vendor))
  end

  test "should create an activity record from finalizing a agreement" do
    @complete_status = agreement_statuses(:four)
    assert_difference('Activity.count', 1 , "Finalize agreement action did not create an acitity record") do
      post :finalize_agreement, id: @agreement, vendor_id: @vendor1, agreement: {agreement_id: @agreement.id, vendor_id: @vendor1.id, active: 1, agreement_status_id: @complete_status.id}
    end
  end
  test "Manage_agreement action can not be accessed if agreement is finalized " do
    @finalized_agreement = agreements(:two)
    get :manage_agreements, id: @finalized_agreement, vendor_id: @vendor1 do
      assert_redirected_to vendor_path(assigns(:vendor)), "User was not redirected away from the manage_agreement page after agreement has been finalized"
      assert_equal flash[:error], "Agreement has been finalized and cannot be edited"
    end
  end

  test "should test the creation of a pdf" do
    @controller.stubs(:render).returns("success")
    @finalized_agreement = agreements(:two)
    get :generate_pdf, id: @finalized_agreement, vendor_id: @vendor1, :format => :pdf do
    assert_match /pdf/, response.headers['Content-Type']
    assert_match /application/, response.headers['Content-Type']
    assert_response :success
   end
  end

  test "should index shipment_file and correct amounts of table headers and cell elements" do
    login_contract_admin
    get :index, id: @agreement
    assert_response :success
    assert_select "th", {count: 6}
    assert_select "td#name_#{@agreement.id}", {text: "#{@agreement.name}"}
  end
end
