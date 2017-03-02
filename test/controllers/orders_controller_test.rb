require 'test_helper'

class OrdersControllerTest < ActionController::TestCase
  setup do
    @order = orders(:one)
    @order2 = orders(:two) #international order since address is from Canada
    @order3 = orders(:three)
    @order4 = orders(:four)
    @order9 = orders(:nine)
    @reviewed_order = orders(:four)
    @review_status = order_statuses(:four)
    @submitted_status = order_statuses(:five)
    @plate_96 = plate_type(:one)
  end

  test "should get index and should only display the orders assigned to a COR" do
    login_cor
    get :index
    assert_response :success
    assert_not_nil assigns(:orders)
    assert_select "tr", 6, "There should only be two TR since one order in fixtures is assinged to this COR"
  end

  test "should get new" do
    login_chemadmin
    get :new
    assert_response :success
  end

  test "should not get new because user is not authorized" do
    login_chemcurator
    @request.env['HTTP_REFERER'] = 'http://chemtrack/activities'
    get :new
    assert_response :redirect
  end

  test "should make sure that checkbox is selected in edit page" do
    login_chemadmin
    get :edit, id: @order
    assert_response :success, "Expected http response was not a success"
    assert_select 'input[type=checkbox][checked=checked]', true, "Checkbox for @order 1 is not selected even though"\
                                                                  "the order is a dried down order"
  end

  test "should create order and should also create a new Chemical List and a mapping between the order and the list" do
    login_chemadmin
    assert_difference('Order.count') do
      post :create, order: {user_id: @order.user.id, vendor_id: @order.vendor.id,
                              task_order_id: @order.task_order.id,
                              order_concentration_id: @order.order_concentration.id, amount: @order.amount,
                              address_id: @order.address.id, order_status: @order.order_status, dried_down: 1}

    end
     join_table = OrderChemicalList.last
     order = Order.last
     assert_equal join_table.order_id, order.id

  end

  test "Should create order_plate_detail record " do
    login_chemadmin
    assert_difference('OrderPlateDetail.count') do
      post :order_plate_detail, {id: @order.id, new_detail: "Submit" , plate_detail: @plate_96.id, format: :js }
      assert_not_nil @response.body
    end
  end

   test "should not add a plate_detail record if none of the selections are chosen is selected" do
     login_chemadmin
     assert_difference('OrderPlateDetail.count', 0) do  #Count should be zero because the user is redirected back
       post :order_plate_detail, {id: @order3.id, new_detail: "Submit", format: :js}
       assert_response :success
     end
   end

  test "should show order" do
    login_chemadmin
    get :show, id: @order3
    assert_response :success
  end

  test "should destroy order" do
    login_chemadmin
    assert_difference('Order.count', -1) do
      delete :destroy, id: @order3
    end

    assert_redirected_to orders_path
  end

  test "postdoc can not delete order" do
    login_postdoc
    @request.env['HTTP_REFERER'] = 'http://chemtrack/order/id'
    assert_difference('Order.count', 0) do
      delete :destroy, id: @order
    end
    assert_response :redirect
  end

  test "cor can place order in review" do
    login_cor
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      assert_difference 'OrderComment.count', 0 do
        post :review_order, {id: @order3, format: :js, rejected: false}
        email = ActionMailer::Base.deliveries.last
        assert_equal "Order has been finalized", email.subject
        assert_equal ['ChemTrack@epa.gov'], email.from
        assert_equal ['ruiz-veve.raymond@epa.gov'], email.to
        assert_match(/An order has been submitted for review by rruizvev/, email.body.to_s)
        assert_response :success
      end
    end
  end


  test "chemadmin can return order back to cor" do
    login_chemadmin
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      @order3.update_attributes(order_status: @review_status ) #action is only available if the order is in review
      patch :order_return_patch, {id: @order3, body: 'Order is being returned', format: :js }
      email = ActionMailer::Base.deliveries.last
      assert_equal "Order has been returned", email.subject
      assert_equal ['ChemTrack@epa.gov'], email.from
      assert_equal ['superadmin@yahoo.com'], email.to
      assert_match(/Order is being returned/, email.body.to_s )
    end
  end

  test "cor can place order in review if order has been returned" do
    login_cor
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      assert_difference 'OrderComment.count' do
        post :review_order, {id: @order3, body: 'Order is being resubmitted', rejected: true, format: :js}
        email = ActionMailer::Base.deliveries.last
        assert_equal "Order has been finalized", email.subject
        assert_equal ['ChemTrack@epa.gov'], email.from
        assert_equal ['ruiz-veve.raymond@epa.gov'], email.to
        assert_match(/An order has been submitted for review by rruizvev/, email.body.to_s)
        assert_match(/Order is being resubmitted/, email.body.to_s)
        assert_response :success
      end
    end
  end

  test "chemadmin can see order_comments_show view and view contents for returning the order " do
    login_chemadmin
    xhr :get, :order_comments_show, id: @order3, format: :js
    assert_response :success
    assert_match /order_return/, @response.body.to_s
  end

  test "cor can see order_comments_show view and contents for re-submitting an order" do
    login_cor
    xhr :get, :order_comments_show, id: @order9, format: :js
    assert_response :success
    assert_match /reviewRejectedOrder/, @response.body.to_s
  end

  test "postdoc can place order in review" do
    login_postdoc
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      post :review_order, {id: @order3, format: :js, rejected: false}
      email = ActionMailer::Base.deliveries.last
      assert_equal "Order has been finalized", email.subject
      assert_equal ['ChemTrack@epa.gov'], email.from
      assert_equal ['ruiz-veve.raymond@epa.gov'], email.to
      assert_match(/An order has been submitted for review by postdoc/, email.body.to_s)
    end
  end

  test "chemadmin can submit an order" do
    login_chemadmin
    post :submit_order, {id: @reviewed_order.id, format: :js } do
      assert_response :success
      assert_not_nil flash[:success]
    end
  end

  test "order_overview action and make sure that the correct plate_count is being displayed and the order is international" do
    login_chemadmin
    get :order_overview, {id: @order3}
    assert_response :success
    assert_template "order_overview"
    assert_select '#international',1
  end

  test "should test the correct order overview information" do
    login_chemadmin
    get :order_overview, {id: @order3}
    assert_response :success
    assert_template "order_overview"
    assert_select 'li#platesNeeded', {:count => 1, text: "Plates Needed: 1", message: 'Wrong plate needed count'}
    assert_select 'li#procurementsNeeded', {:count => 1, text: "Procurements Needed: 2", message: 'Wrong procurement needed count'}
    assert_select 'li#dilutionsNeeded', {:count => 1, text: "Dilutions Needed: 0", message: 'Wrong dilution needed count'}
    assert_select 'li#solubilizationsNeeded', {:count => 1, text: "Solubilizations Needed: 0", message: 'Wrong dilution needed count'}
  end
  
  test "should make sure that the correct number of controls are being displayed in show plate view" do
    login_superadmin
    get :show_plate, {id: @order}
    assert_select 'table#list-controls-table td#rowControl', 'CTRL1'
    assert_select 'table#list-controls-table td#rowControl', {:count => 1}
    assert_response :success
  end

  test "option pull down is not available if the order is in review for a cor in the order_overview view, cor can't send order back into progress" do
    login_cor
    @order4.update_attributes(order_status: @review_status) #action is only available if the order is in review
    get :order_overview, {id: @order4}
    assert_response :success
    assert_template "order_overview"
    assert_select '#optionPulldown', {:count => 0}
    @request.env['HTTP_REFERER'] = 'http://chemtrack/orders/'
    assert_difference 'OrderComment.count', 0, 'A COR can not return an order back' do
      patch :order_return_patch, {id: @order4, body: 'Order is being returned', format: :js}
      assert_response :redirect
    end
  end

  test "option pull down is available if the order is in review for a chemadmin in the order_overview view " do
    login_chemadmin
    @order4.update_attributes(order_status: @review_status ) #action is only available if the order is in review
    get :order_overview, {id: @order4}
    assert_response :success
    assert_template "order_overview"
    assert_select '#optionPulldown', {:count => 1}
  end

  test "user should not see font awesome icon if the order is not in progress and/or if there are no comments" do
    login_cor
    get :show_plate, {id: @order4} do
    assert :success
    assert_select '#commentIcon', {:count => 0} #shold not see icon since there are no comments
    end
    @order3.update_attributes(order_status: @submitted_status) #action is only available if the order is in review
    get :order_overview, {id: @order3} do  #order 3 does have comments!
      assert_select '#commentIcon', {:count => 0} #shold not see icon since there are no comments
    end
  end

  test "should create a order excel file" do
    login_chemadmin
    post :export_order_file, {id: @order3.id, order_id: @order3.id}
    assert_response :success
    assert_equal 'application/vnd.ms-excel', response.headers['Content-Type']
    date = Time.now.strftime('%Y%m%d')
    filename = "order_review_#{date}.xls"
    assert_match /#{filename}/, response.headers['Content-Disposition'].to_s
    File.open(filename, 'w:ASCII-8BIT') {|f| f.puts response.body }
    results1 = Spreadsheet.open(filename).worksheet(0)
    results2 = Spreadsheet.open(filename).worksheet(1)
    assert_not_nil results1
    assert_not_nil results2
    row1_results1 = results1.row(0)
    row1_results2 = results2.row(0)
    expected_results1 = Regexp.union(/gsid/, /preferred_name/, /casrn/, /DTXSID/)
    expected_results2 = Regexp.union( /Vendor/, /Address/, /Country/, /State/,/City/, /Zipcode/)
    row1_results1.each do |attribute|
      assert_match expected_results1, attribute
    end
    row1_results2.each do |attribute|
      assert_match expected_results2, attribute
    end
    #number of counts should equal to number of chemicals in order, needed to substract 1 since header is included in count in results
    assert_equal results1.count-1, @order3.available_chemicals.count + @order3.not_available_chemicals.count
    File.delete(filename)
  end

  test "user should see message icon if the order is in progress and if there are comments " do
    login_cor
    get :order_overview, {id: @order3} do  #order 3 does have comments and its also in progress!
      assert_select '#commentIcon', {:count => 1} #shold not see icon since there are no comments
    end
  end
  
end
