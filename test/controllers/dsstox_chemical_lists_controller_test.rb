require 'test_helper'
class ChemicalListsControllerTest < ActionController::TestCase

  setup do
    @cor1 = users(:cor)
    @order_cor1 = orders(:six)
    @chemical_list = chemical_lists(:seven)
  end

  test "should get show and only show the chemcical lists that are private to COR and begin with TOXCST" do
    login_cor
    get :show, id: @chemical_list, order_id: @order_cor1
    assert_response :success
    lists = css_select("select#chemical-lists option").map(&:text)
    assert_equal %w[chemical_list MyListTwo MyListOne test_chemtrack_rruizvev_COA_Summary_Chemical_List test_chemtrack_COA_Summary_Chemical_List TOXCST_list], lists
  end


end