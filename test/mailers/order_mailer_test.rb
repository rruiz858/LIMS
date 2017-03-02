require 'test_helper'

class OrderMailerTest < ActionMailer::TestCase
  setup do
    @order = orders(:one)
    @chemadmin = users(:chemadmin)
    @current_user = users(:superadmin)
  end

test "order_confimation" do
  email =  OrderMailer.order_confirmation(@order, @chemadmin, @current_user).deliver_now
  assert_not ActionMailer::Base.deliveries.empty?
  assert_equal ['ruiz-veve.raymond@epa.gov'], email.to
  assert_equal 'Order has been finalized', email.subject
end

end
