require 'test_helper'
require 'database_cleaner'
DatabaseCleaner.strategy = :deletion
class ChemContractTest < ActionDispatch::IntegrationTest
  self.use_transactional_fixtures = false
  setup do
    Capybara.default_driver = :selenium
    @superadmin = users(:superadmin)
    @chemadmin = users(:chemadmin)
    @contract_admin = users(:contract_admin)
    window = Capybara.current_session.driver.browser.manage.window
    window.resize_to(1024,768)
  end

  def teardown
    DatabaseCleaner.clean
    Capybara.reset_sessions!
  end

  test "Agreement Admin can create/edit vendors" do
    visit('/vendors')
    fill_in('email', :with => @contract_admin.email)
    fill_in('password', :with => "password")
    click_button('sign_in')
    click_button('new-order-vendor')
    fill_in('VendorName', :with => "Vendor1")
    fill_in('VendorLabel', :with => "Vendor1-label")
    fill_in('VendorPhone', :with => "545-453-4563")
    fill_in('VendorDetails', :with => "Hi there, I am a cool Vendor that everyone wants a peice off")
    click_button('vendorSubmit')
  end
end