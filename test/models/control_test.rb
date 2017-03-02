require 'test_helper'

class ControlTest < ActiveSupport::TestCase

  test "should test the order control method " do
    @order = orders(:one)
    controls = Control.order_controls(@order.id)
    assert_not_nil controls
    controls.each do |control|
      assert_not_nil control.identifier
      assert_not_nil control.casrn
      assert_not_nil control.preferred_name
    end
  end
end