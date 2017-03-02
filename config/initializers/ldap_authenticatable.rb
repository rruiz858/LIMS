unless Rails.env.test?
require 'net/ldap'
require 'devise/strategies/authenticatable'
module Devise
  module Strategies
    class LdapAuthenticatable < Authenticatable

      def authenticate!
        if params[:user]
          ldap = Net::LDAP.new
          ldap.host = 'v1818tncyt205.aa.ad.epa.gov'
          ldap.port = '389'
          ldap.auth login, password

          if ldap.bind && password.present?
            user = User.find_by(email: login)
            success!(user)
          else
            fail(:invalid_login)
          end
        end
      end

      def email
        params[:user][:email]
      end

      def password
        params[:user][:password]
      end

      def login
        @user = User.find_by(email: email)
        if !(@user.nil?)
          @user.email
        elsif @user.nil?
          @user = User.find_by(username: email)
          if !(@user.nil?)
            @user.email
          else
            "noemail@gmail.com"
        end
      end
     end

    end
  end
end

Warden::Strategies.add(:ldap_authenticatable, Devise::Strategies::LdapAuthenticatable)
end