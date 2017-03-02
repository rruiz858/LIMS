require 'test_helper'

class AddressTest < ActiveSupport::TestCase
  setup do
    @address = Address.new
  end

  test "should not save address without address1" do
    @address.address1 = nil
    assert_not @address.save, "\nERROR - Your Address Model saved an address and DID NOT \n" \
                            "        check the presence of an address1 attribute!\n"
  end

  test "should not save address without city" do
    @address.city = nil
    assert_not @address.save, "\nERROR - Your Address Model saved an address and DID NOT \n" \
                            "        check the presence of a city attribute!\n"
  end

  test "should not save address without country" do
    @address.country = nil
    assert_not @address.save, "\nERROR - Your Address Model saved an address and DID NOT \n" \
                            "        check the presence of a country attribute!\n"
  end

  test "should not save address without state if the country specified is the United States" do
    @address.country = 'United States'
    assert_not @address.save, "\nERROR - Your Address Model saved an address and DID NOT \n" \
                            "        check the presence of a state attribute!\n"
    assert_not_nil @address.errors.messages[:state], "This address was saved even though the county is the United States"
    assert_match /can't be blank/, @address.errors.messages[:state].to_s

  end

  test "should not save address without zip" do
    @address.zip = nil
    assert_not @address.save, "\nERROR - Your Address Model saved an address and DID NOT \n" \
                            "        check the presence of a zip attribute!\n"
  end
  test "should not save address without vendor_id" do
    @address.vendor_id = nil
    assert_not @address.save, "\nERROR - Your Address Model saved an address and DID NOT \n" \
                            "        have the presence of a vendor_id foreign key attribute!\n"
  end

  test "should not save an address if override_city attribute is set to false " do
    @address = addresses(:fox_hunt)
    @address.override_city = 'false'
    @address.city = nil
    assert @address.invalid?, "\nERROR - City validation is not checking for presence when override attribute is set to false... BAD"
    assert @address.errors[:city].any?
    assert_match /can't be blank/,  @address.errors[:city].to_s
    assert_not @address.save, "\nERROR - Address model saved an address without a city params.  That's not allowed..."
  end

  test "should  save an address if override_city attribute is set to true " do
    @address = addresses(:fox_hunt)
    @address.override_city = 'true'
    @address.city = nil
    assert @address.save, "\nERROR - Address model is not saving addresses when the override paramater is set to true"
  end

end
