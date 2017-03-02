require 'test_helper'

class WelcomeControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should log in valid user" do
    login_postdoc do
      get :index
      assert_select "current_user.f_name"
    end
  end


  test " test for the root of the application" do
    get = {:controller => 'welcome', :action => 'index'}
    assert_recognizes get, '/'
  end

end

