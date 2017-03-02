require 'test_helper'
require 'database_cleaner'
DatabaseCleaner.strategy = :deletion
class CoaSummaryIndexTest < ActionDispatch::IntegrationTest
  self.use_transactional_fixtures = false
  setup do
    Capybara.default_driver = :selenium
    @superadmin = users(:superadmin)
    @chemadmin = users(:chemadmin)
    @contract_admin = users(:contract_admin)
    window = Capybara.current_session.driver.browser.manage.window
    window.resize_to(1024,768)

  end

  test "should show the correct number of links for coa and msds" do
    visit('/coa_summaries')
    fill_in('email', :with => @superadmin.email)
    fill_in('password', :with => "password")
    click_button('sign_in')
    click_link('Curated Records')
    assert_match "true", page.assert_selector('a.coa-msds-pdf', :count => 2).to_s
  end

  test "should display a red cell on uncurated names and casrns that come from the bottles table as opposed a coa summary file" do
    visit('/coa_summaries')
    fill_in('email', :with => @superadmin.email)
    fill_in('password', :with => "password")
    click_button('sign_in')
    click_link('Uncurated Records')
    count = CoaSummary.uncurated.count
    assert_equal "true", page.assert_selector('#uncuratedMainCount', :text => "#{count}").to_s
    assert_equal "true", page.assert_selector('#badgename-other', :text => 1).to_s
    assert_equal "false", page.has_css?('#badgename').to_s
    click_link('name-other')
    page.assert_selector("td#nameTest-Mom", {visible: 'background-color rgb(255, 230, 230)'})
  end

end