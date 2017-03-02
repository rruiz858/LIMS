require 'test_helper'

class ContactTest < ActiveSupport::TestCase
  setup do
    @contact = Contact.new
    @vendor = vendors(:vendor1)
  end

  test "should not save contact without name" do
    @contact.first_name = nil
    assert_not @contact.save, "\nERROR - An contact was saved without a name!"
    assert_match "can't be blank", @contact.errors.messages[:first_name].to_s
  end

  test "should not save contact without a last_name" do
    @contact.last_name = nil
    assert_not @contact.save, "\nERROR - An contact was saved without a last name!"
    assert_match "can't be blank", @contact.errors.messages[:last_name].to_s
  end
  test "should not save contact without a phone" do
    @contact.phone1 = nil
    assert_not @contact.save, "\nERROR - An contact was saved without a phone!"
    assert_match "can't be blank", @contact.errors.messages[:phone1].to_s
  end
  test "should not save contact without an email " do
    @contact.email = nil
    assert_not @contact.save, "\nERROR - An contact was saved without an email!"
    assert_match "can't be blank", @contact.errors.messages[:email].to_s
  end

  test "should not save contact without a contact_type" do
    @contact.contact_type_id = nil
    assert_not @contact.save, "\nERROR - An contact was saved without a contact_type!"
    assert_match "can't be blank", @contact.errors.messages[:contact_type].to_s
  end

end
