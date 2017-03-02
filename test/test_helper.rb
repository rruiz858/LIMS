ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'selenium/client'
require 'mocha/mini_test'
require 'capybara/rails'


class ActiveSupport::TestCase
  extend ActionDispatch::TestProcess
  fixtures :all
  CarrierWave.root = Rails.root.join('test/fixtures/files')
  self.use_transactional_fixtures = false
end


class ActionDispatch::IntegrationTest
  include Capybara::DSL
  ##This was done to slow down selenium.
  # module ::Selenium::WebDriver::Remote
  #   class Bridge
  #     def execute(*args)
  #       res = raw_execute(*args)['value']
  #       sleep 0
  #       res
  #     end
  #   end
  # end
end

class ActionController::TestCase
  include ActionDispatch::TestProcess
  include Devise::TestHelpers
  extend ActionDispatch::TestProcess
  self.use_transactional_fixtures = false

  #test helper to login as a superadmin
  def login_superadmin(user = users(:superadmin))
    sign_in :user, user
  end
  def login_chemadmin(user = users(:chemadmin))
    sign_in :user, user
  end
  def login_chemcurator(user = users(:chemcurator))
    sign_in :user, user
  end
  def login_cor(user = users(:cor))
    sign_in :user, user
  end
  def login_postdoc(user = users(:postdoc))
    sign_in :user, user
  end
  def login_contract_admin(user = users(:contract_admin))
    sign_in :user, user
  end
end

