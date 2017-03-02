require 'test_helper'

class TaskOrdersControllerTest < ActionController::TestCase
  setup do
    login_contract_admin
    @vendor1 = vendors(:vendor1)
    @agreement = agreements(:two)
    @status = agreement_statuses(:two)
    @user = users(:chemadmin)
    @task_order = task_orders(:one)
    @vendor_path = ENV["DIR_PATH"]
    @hash = {name: "NewName", description: "Hi mom",
             vendor: @vendor1.id,
             agreement: @agreement.id,
             user: @user.id,
             vendor_name: @vendor1.name }
  end

  test "should get new" do
    get :new, vendor_id: @vendor1, agreement_id: @agreement
    assert_response :success
  end

  test "should create task_order" do
    assert_difference('TaskOrder.count') do
      post :create, vendor_id: @vendor1, agreement_id: @agreement, id: @task_order,
           task_order: { vendor_id: @hash[:vendor], agreement_id: @hash[:agreement],
                         name: @hash[:name], description: @hash[:description],
                         created_by: @hash[:user]
           }
    end
    new_path = @vendor_path + "/#{@hash[:vendor_name]}"
    FileUtils.rm_rf(new_path)
    assert_redirected_to vendor_path(assigns(:vendor))
  end


  test "should get edit" do
    get :edit, id: @task_order, vendor_id: @vendor1, agreement_id: @agreement.id
    assert_response :success
  end

  test "should update task_order" do

    patch :update, vendor_id: @vendor1, agreement_id: @agreement, id: @task_order,
          task_order: { vendor_id: @vendor1.id, agreement_id: @agreement.id,
                        name: @task_order.name, description: @task_order.description,
                        created_by: @user.username
          }
    assert_redirected_to vendor_path(assigns(:vendor))
  end


end
