require 'test_helper'

class OrderCommentsControllerTest < ActionController::TestCase

  def setup
    @comment = order_comments(:one)
    @order = orders(:three)
    @submitted_status = order_statuses(:five)
  end

  test "should get index" do
    login_superadmin
    xhr :get, :all_comments, order_id: @order.id, format: :js
    assert_response :success
  end

  test "should create a new comment" do
    login_superadmin
    xhr :get, :all_comments, order_id: @order.id, format: :js
    assert_response :success
    assert_difference('OrderComment.count', 1, 'A new comment was not created') do
      post :create, {order_id: @order.id, body: 'Im a new comment!' , format: :js }
    end
  end

  test "should not get all_comments or create a new comment if the order is not in progress or review" do
    login_cor
    @request.env['HTTP_REFERER'] = 'http://chemtrack/orders/'
    @order.update_attributes(order_status: @submitted_status) #action is only available if the order is in review
    xhr :get, :all_comments, order_id: @order.id, format: :js
    assert_response :redirect
    assert_difference('OrderComment.count', 0, 'A new comment was created when it shouldn\'t have') do
      post :create, {order_id: @order.id, body: 'Im a new comment!' , format: :js }
      assert_response :redirect
    end
  end

end
