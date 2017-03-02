require 'test_helper'

class AgreementTest < ActiveSupport::TestCase
  test "the truth" do
    assert true
  end

  setup do
    @agreement = Agreement.new
    @vendor = vendors(:vendor1)
    @agreement2 = agreements(:two)
    @user = users(:chemadmin)
  end

  test "should not save agreement without name" do
    @agreement.name = nil
    assert_not @agreement.save, "\nERROR - An address was saved without a name!"
    assert_match "can't be blank", @agreement.errors.messages[:name].to_s
  end
  test "should not save agreement without a user_id" do
    @agreement.user = nil
    assert_not @agreement.save, "\nERROR - A agreement was saved without a user!"
    assert_match "can't be blank", @agreement.errors.messages[:user_id].to_s
  end


  test "should not save agreement without a description" do
    @agreement.description = nil
    assert_not @agreement.save, "\nERROR - An address was saved without a description!"
    assert_match "can't be blank", @agreement.errors.messages[:description].to_s
  end

  test "should not save agreement without a parent vendor" do
    @agreement.vendor_id = nil
    assert_not @agreement.save, "\nERROR - An address was saved without a vendor!"
    assert_match "can't be blank", @agreement.errors.messages[:vendor_id].to_s
  end

  test "should test the before_create method that assings a status of new to a agreement" do
    @new_agreement = Agreement.create(name: 'Test', description: 'This is only a test', vendor_id: @vendor.id, user_id: @user.id )
    assert_equal "New", @new_agreement.agreement_status.status
  end


  test "should not tag a agreement as active if there is no expiration date defined" do
    @new_agreement = Agreement.new(:active => 1, :name => "mom", :description => "hi", :vendor_id => @vendor.id)
    assert_not @new_agreement.save, "\nERROR - A agreement was saved without an expiration date"
    assert_match "can't be blank", @new_agreement.errors.messages[:expiration_date].to_s
  end

  test "should not revoke a agreement if no message was added" do
    @revoked_status = agreement_statuses(:five)
    @agreement2.agreement_status = @revoked_status
    assert_not @agreement2.save, "\nERROR - A agreement was revoked  without an revoked_reason"
    assert_match "can't be blank", @agreement2.errors.messages[:revoke_reason].to_s
  end
end
