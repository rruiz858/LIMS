require 'test_helper'

class QueriesControllerTest < ActionController::TestCase
  setup do
    @query1 = queries(:one)
    @query2 = queries(:two)
  end

  test "admin should get new" do
    login_superadmin
    get :new
    assert_response :success
  end

  test "chemadmin should not get new and get redirected" do
    login_chemadmin
    @request.env['HTTP_REFERER'] = 'http://chemtrack/activities'
    get :new
    assert_response :redirect
  end

  test "admin should get edit" do
    login_superadmin
    get :edit, id: @query1
    assert_response :success
  end

  test "chemadmin should not get edit and get redirected" do
    login_chemadmin
    @request.env['HTTP_REFERER'] = 'http://chemtrack/activities'
    get :edit, id: @query1
    assert_response :redirect
  end

  test "admin should get show" do
    login_superadmin
    get :show, id: @query1
    assert_response :success
  end


  test "chemadmin should not get show and get redirected" do
    login_cor
    get :show, id: @query1
    assert_response :redirect
    assert_match /Uh-Oh you are being naughty/, flash[:notice].to_s
  end

  test "admin can update query" do
    login_superadmin
    patch :update, id: @query1, query: {name: "Plate Details", label: "Plate Detail count",
                                        description: @query1.description, conditions: '',
                                        sql: 'plate_details'}
    assert_redirected_to query_path(assigns(:query))
  end

  test "chemadmin can update_all queries" do
    login_chemadmin
    post :update_all, format: :json
    assert_response :success
  end

  test "anauthorized user can not update_all queries" do
    login_cor
    post :update_all, format: :json
    assert_response :redirect
    assert_match /Uh-Oh you are being naughty/, flash[:notice].to_s
  end

end