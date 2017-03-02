require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "should respond to comits" do
    user = users(:superadmin)
    assert_respond_to user, :comits
  end

  test "should respond to activities" do
    user = users(:superadmin)
    assert_respond_to user, :activities
  end

  test "should not save an email that is not unique " do
    user = User.new(email: "ruiz-veve.raymond@epa.gov")
    assert !user.save
    assert_match /This email is already taken/, user.errors[:email].to_s
  end
  test "should not save a user without a Role " do
    user = User.new(f_name: "Cary")
    assert !user.save
    assert_match /Must select a role/, user.errors[:role_id].to_s
  end

  test "should not save a user without a username" do
    user = User.new(f_name: "John")
    assert !user.save
    assert_match /Must include username/, user.errors[:username].to_s
  end
end
