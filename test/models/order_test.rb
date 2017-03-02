require 'test_helper'

class OrderTest < ActiveSupport::TestCase

  setup do
    @order = orders(:one)
    @order3 = orders(:three)
  end

  test "postdocs can update but not delete orders" do
    user = users(:postdoc)
    ability = Ability.new(user)
    assert ability.can?(:update, @order)
    assert ability.cannot?(:destroy, @order)
  end

  test "cors can CRUD orders" do
    user = users(:cor)
    ability = Ability.new(user)
    @cor_order = Order.new(:user => user)
    assert ability.can?(:create, Order)
    assert ability.can?(:update, @cor_order)
    assert ability.can?(:destroy, @cor_order)
  end

  test "should text the plate needed method" do
    assert_respond_to(@order3, :plates_needed, 'order instance does not respond to the plate needed public method')
    plates = @order3.plates_needed
    assert_instance_of(Order, @order3, "object is not an instance of Order")
    assert_not_nil plates, "plate method did not find a count"
    assert_equal 1, plates, "plate count did not equal to one"
  end

  test "should test the procurements method" do
    assert_respond_to(@order3, :procurements, 'order instance does not respond to the procurement public method')
    procurements = @order3.procurements
    assert_instance_of(Order, @order3, "object is not an instance of Order")
    assert_not_nil procurements, "procurements method did not find a count"
    assert_equal 2, procurements, "procurements count did not equal to two"
  end

  test "should test the not available chemical " do
    assert_respond_to(@order3, :not_available_chemicals, 'order instance does not respond to the not available chemials public method')
    not_available = @order3.not_available_chemicals
    assert_instance_of(Order, @order3, "object is not an instance of Order")
    assert_not_nil not_available, "not_available method did not find a count"
    assert_equal 2, not_available.count, "not_available count did not equal to one"
  end

  test "should test the available methdod" do
    assert_respond_to(@order3, :not_available_chemicals, 'order instance does not respond to the available chemials public method')
    available = @order3.available_chemicals
    assert_instance_of(Order, @order3, "object is not an instance of Order")
    assert_not_nil available, "available method did not find a count"
    assert_equal 0, available.count, "available count did not equal to 0"
  end


end