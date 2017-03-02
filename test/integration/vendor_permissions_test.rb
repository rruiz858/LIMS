require 'test_helper'
require 'database_cleaner'
DatabaseCleaner.strategy = :deletion
class VendorPermissionsTest < ActionDispatch::IntegrationTest
  self.use_transactional_fixtures = false
  setup do
    Capybara.default_driver = :selenium
    @superadmin = users(:superadmin)
    @chemadmin = users(:chemadmin)
    @cor1 = users(:cor)
    @postdoc = users(:postdoc)
    @contract_admin = users(:contract_admin)
    @vendors1 = vendors(:vendor1)
    @chemcurator = users(:chemcurator)
  end

  def teardown
    DatabaseCleaner.clean
    Capybara.reset_sessions!
  end

  test "admin can view and edit all contracts and vendors" do
    visit ("/vendors/#{@vendors1.id}")
    fill_in('email', :with => @superadmin.email)
    fill_in('password', :with => "password")
    click_button('sign_in')
    click_link('editVendor')
    assert_match "/vendors/#{@vendors1.id}/edit", current_path
    visit ("/vendors/#{@vendors1.id}")
    click_link('Agreements')
    click_button('newAgreement')
    assert_match "/vendors/#{@vendors1.id}/agreements/new", current_path
    click_link('backAgreement')
    click_link('Contacts')
    click_button('newContact')
    assert_match "/vendors/#{@vendors1.id}/contacts/new", current_path
  end

  test "chemadmin can view and edit all contracts and vendors" do
    visit ("/vendors/#{@vendors1.id}")
    fill_in('email', :with => @chemadmin.email)
    fill_in('password', :with => "password")
    click_button('sign_in')
    click_link('editVendor')
    assert_match "/vendors/#{@vendors1.id}/edit", current_path
    visit ("/vendors/#{@vendors1.id}")
    click_link('Agreements')
    click_button('newAgreement')
    assert_match "/vendors/#{@vendors1.id}/agreements/new", current_path
    click_link('backAgreement')
    click_link('Contacts')
    click_button('newContact')
    assert_match "/vendors/#{@vendors1.id}/contacts/new", current_path
  end

  test "contract_admin can view and edit all contracts and vendors" do
    visit ("/vendors/#{@vendors1.id}")
    fill_in('email', :with => @contract_admin.email)
    fill_in('password', :with => "password")
    click_button('sign_in')
    click_link('editVendor')
    assert_match "/vendors/#{@vendors1.id}/edit", current_path
    visit ("/vendors/#{@vendors1.id}")
    click_link('Agreements')
    click_button('newAgreement')
    assert_match "/vendors/#{@vendors1.id}/agreements/new", current_path
    click_link('backAgreement')
    click_link('Contacts')
    click_button('newContact')
    assert_match "/vendors/#{@vendors1.id}/contacts/new", current_path
  end

  test "cor can view and edit all agreements and contacts that they belong to" do
    visit ("/vendors/#{@vendors1.id}")
    fill_in('email', :with => @cor1.email)
    fill_in('password', :with => "password")
    click_button('sign_in')
    assert_match "true", page.assert_no_selector('editVendor').to_s
    click_link('Agreements')
    assert_match "true", page.assert_no_selector('newAgreement').to_s
    click_link('Contacts')
    assert_match "true", page.assert_no_selector('newContact').to_s
  end

  test "postdoc can see all vendors and contacts" do
    visit ("/vendors/#{@vendors1.id}")
    fill_in('email', :with => @postdoc.email)
    fill_in('password', :with => "password")
    click_button('sign_in')
    assert_match "true", page.assert_no_selector('editVendor').to_s
    click_link('Contacts')
    assert_match "true", page.assert_no_selector('newContact').to_s
  end

  test "chemcurator can see all vendors and contacts" do
    visit ("/vendors/#{@vendors1.id}")
    fill_in('email', :with => @chemcurator.email)
    fill_in('password', :with => "password")
    click_button('sign_in')
    assert_match "true", page.assert_no_selector('editVendor').to_s
    click_link('Contacts')
    assert_match "true", page.assert_no_selector('newContact').to_s
  end

end
