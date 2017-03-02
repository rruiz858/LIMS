require 'test_helper'

class TaskOrderTest < ActiveSupport::TestCase
  setup do
    @vendor1 = vendors(:vendor1)
    @agreement = agreements(:two)
    @status = agreement_statuses(:two)
    @user = users(:chemadmin)
    @task_order = task_orders(:one)
  end

  test "the truth" do
    assert true
  end

  test "should not save task order without name" do
    @task_order.name = nil
    assert_not @task_order.save, "\nERROR - An task order was saved without a name!"
    assert_match "can't be blank", @task_order.errors.messages[:name].to_s
  end

  test "should not save task order without description" do
    @task_order.description = nil
    assert_not @task_order.save, "\nERROR - An task order was saved without a description!"
    assert_match "can't be blank", @task_order.errors.messages[:description].to_s
  end
  test "should not save task order without a vendor" do
    @task_order.vendor = nil
    assert_not @task_order.save, "\nERROR - An task order was saved without a vendor!"
    assert_match "can't be blank", @task_order.errors.messages[:vendor_id].to_s
  end

  test "should not save task order without a agreement" do
    @task_order.agreement = nil
    assert_not @task_order.save, "\nERROR - An task order was saved without a agreement!"
    assert_match "can't be blank", @task_order.errors.messages[:agreement_id].to_s
  end

end
