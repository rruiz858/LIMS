require 'test_helper'

class ActivitiesControllerTest < ActionController::TestCase

  test "Should display saved query panel if authorized, chemadmin can't edit queries " do
   login_chemadmin
   get :index
   assert_select '#queryResultsTable', {:count => 1}
   assert_select 'table#queryTable tr', {:count => 3}
   assert_select 'table#queryTable th#editQueryColumn', {:count => 0}
  end

  test "Should display saved query panel if authorized " do
    login_superadmin
    get :index
    assert_select '#queryResultsTable', {:count => 1}
    assert_select 'table#queryTable tr', {:count => 3}
    assert_select 'table#queryTable th#editQueryColumn', {:count => 1}
  end

  test "Should not display saved query panel if authorized " do
    login_cor
    get :index
    assert_select '#queryResultsTable', {:count => 0}
    assert_select 'table#queryTable tr', {:count => 0}
    assert_select 'table#queryTable th#editQueryColumn', {:count => 0}
  end

end
