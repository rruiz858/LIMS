require 'test_helper'
require 'database_cleaner'
DatabaseCleaner.strategy = :deletion
class TestUserFlowsTest < ActionDispatch::IntegrationTest
  self.use_transactional_fixtures = false
  setup do
    Capybara.default_driver = :selenium
    @superadmin = users(:superadmin)
    @chemadmin = users(:chemadmin)
    @cor1 = users(:cor)
    @cor2 = users(:cor2)
    @postdoc = users(:postdoc)
    @order_cor1 = orders(:four)
    @reviewed_order_cor1= orders(:eight)
    @source_substance = source_substances(:two)
    @source_substance3 = source_substances(:three)
    @source_generic_substance = source_generic_substances(:two)
    @mentor_postdoc = mentor_postdocs(:one)
    @order_submitted = orders(:nine)
    window = Capybara.current_session.driver.browser.manage.window
    window.resize_to(1024,768)
  end

  def teardown
    DatabaseCleaner.clean
    Capybara.reset_sessions!
  end

  test "unsigned user can view bottles" do
    visit('/')
    click_button('multipleBottleSearch')
    assert true
  end

  test "login as superadmin and view all orders, a super admin can also manage users" do
    visit('/activities')
    fill_in('email', :with => @superadmin.email)
    fill_in('password', :with => "password")
    click_button('sign_in')
    assert_match "true", page.has_selector?('#activity-stream').to_s
    assert_match "/activities", current_path
    visit('/orders')
    assert_match "true", page.assert_selector('tr#order_count', :count => 10 ).to_s
  end

  test "COR can only see orders that belong to them, they can also create orders" do
    visit('/orders')
    fill_in('email', :with => @cor1.email)
    fill_in('password', :with => "password")
    click_button('sign_in')
    assert_match "/orders", current_path
    assert_match "true", page.assert_selector('tr#order_count', :count => 5).to_s
    click_button('new-order-button')
    select("MyVendor2Name", :from => "vendor_id")
    select "20", :from => "order_concentration_id"
    fill_in('order_amount', :with => "100")
    click_button('create-order')
  end

  test "postdoc can only see orders that belong to their cors, they can not add/destroy orders, test also checks to see if multiple gsid system is functioning" do
    visit('/orders')
    fill_in('email', :with => @postdoc.email)
    fill_in('password', :with => "password")
    click_button('sign_in')
    assert_match "true", page.assert_no_selector('delete_order').to_s #this user does not see the delete capabilities
    click_link("chemicalList-#{@order_cor1.id}")
    select "MyListOne", :from => "chemical-lists"
    click_button('add-list')
    click_link('multiple-gsids')
    select "#{@source_generic_substance.generic_substance.id}", :from => "select-gsid"
    click_button('submit-gsid')
    click_link('back-to-chemicals')
    #by selecting this list once more, user will be able to see duplicate records be flagged
    select "MyListOne", :from => "chemical-lists"
    click_button('add-list')
    find("input[type='checkbox']").click  #selects
    find("input[type='checkbox']").click  #unselects
  end

  test "cor can update chemicals within an order that belong to them" do
    visit('/orders')
    fill_in('email', :with => @cor1.email)
    fill_in('password', :with => "password")
    click_button('sign_in')
    click_link("chemicalList-#{@order_cor1.id}")
    select "MyListOne", :from => "chemical-lists"
    click_button('add-list')
    click_link('multiple-gsids')
    select "#{@source_generic_substance.generic_substance.id}", :from => "select-gsid"
    click_button('submit-gsid')
    click_link('back-to-chemicals')
    select "MyListOne", :from => "chemical-lists"
    click_button('add-list')
    find("input[type='checkbox']").click  #selects
    find("input[type='checkbox']").click  #unselects
  end

  test "cor can place order into review" do
    visit("/orders/#{@order_cor1.id}/order_overview")
    fill_in('email', :with => @cor1.email)
    fill_in('password', :with => "password")
    click_button('sign_in')
    assert_match "/orders/#{@order_cor1.id}/order_overview", current_path
    click_button('reviewOrderButton')
  end

  test "chemadmin can submit an order in review" do
    visit("/orders/#{@reviewed_order_cor1.id}/order_overview")
    fill_in('email', :with => @chemadmin.email)
    fill_in('password', :with => "password")
    click_button('sign_in')
    click_button('orderButtonOptions')
    click_button('submitOrderButton')
  end

  test " cor2 can not see nor navigate using url to other cor's orders" do
    visit('/orders')
    fill_in('email', :with => @cor2.email)
    fill_in('password', :with => "password")
    click_button('sign_in')
    assert_match "true", page.assert_no_selector("orderPlate-#{@order_cor1.id}").to_s
  end

  test "postdoc can place the order into review" do
    visit("/orders/#{@order_cor1.id}/order_overview")
    fill_in('email', :with => @postdoc.email)
    fill_in('password', :with => "password")
    click_button('sign_in')
    assert_match "/orders/#{@order_cor1.id}/order_overview", current_path
    click_button('reviewOrderButton')
  end

  test "chemadmin can view all chemical lists" do
    visit('/orders')
    fill_in('email', :with => @chemadmin.email)
    fill_in('password', :with => "password")
    click_button('sign_in')
    assert_match "/orders", current_path
    click_link("chemicalList-#{@order_cor1.id}")
    options = find('#chemical-lists').all('option').collect(&:text)
    count = options.length
    assert_equal count, 10
    assert_equal %w(chemical_list MyListTwo MyListThree MyListOne
                    test_chemtrack_rruizvev_COA_Summary_Chemical_List
                    ChemTrack\ Standard\ Controls
                    test_chemtrack_jsmith09_COA_Summary_Chemical_List
                    test_chemtrack_COA_Summary_Chemical_List
                    test_chemtrack_jpearc03_COA_Summary_Chemical_List
                    TOXCST_list ), options
  end

  test "chemadmin can not destroy an order" do
    visit('/orders')
    fill_in('email', :with => @chemadmin.email)
    fill_in('password', :with => "password")
    click_button('sign_in')
    assert_match "/orders", current_path
    assert_match "true", page.assert_no_selector('delete_order').to_s
  end

  test "cor cannot delete an order that has been submitted" do
    visit('/orders')
    fill_in('email', :with => @cor1.email)
    fill_in('password', :with => "password")
    click_button('sign_in')
    assert_match "true", page.assert_no_selector('delete_order').to_s
  end

  test "test bottle search" do
    visit('/')
    fill_in('bottle-search-bar', :with => "Aspirin") #work with preferred name
    click_button('bottle-search-button')
    fill_in('bottle-search-bar', :with => "50-78-2") #works with casrn
    click_button('bottle-search-button')
    fill_in('bottle-search-bar', :with => "20108") #works with gsid
    click_button('bottle-search-button')
    fill_in('bottle-search-bar', :with => "20001") #works with being in Dsstox but not in Bottle table
    click_button('bottle-search-button')
    fill_in('bottle-search-bar', :with => "Llamas") #work with if does not exist
    click_button('bottle-search-button')
  end

end
