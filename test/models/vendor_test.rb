require 'test_helper'

class VendorTest < ActiveSupport::TestCase

  test "should not save vendor without name" do
    vendor = Vendor.new
    assert_not vendor.save, "\nERROR - Your Vendor Model saved a vendor and DID NOT \n" \
                            "        check the presence of a name attribute!\n"
  end

  test "should not save duplicate vendor" do
    # Database is loaded with fixtures already.
    # Get a duplicate vendor.
    vendor = Vendor.new(name: vendors(:vendor1).name)
    # vendor.invalid should be true because it is a duplicate.
    assert vendor.invalid?, "\nERROR - Duplicates ARE NOT being checked..."

    assert vendor.errors[:name].any?

    # If you save the dup you get false.
    # not false is true...
    assert_not vendor.save, "\nERROR - Your Vendor Model saved a duplicate vendor.  That's not allowed..."
  end

  test "should not have attribute errors" do
    # A catch-all for now...
    vendor = vendors(:vendor1)
    assert_not vendor.errors[:label].any?, "\nERROR - Fixture vendor1.label has issues..."
    assert_not vendor.errors[:phone1].any?, "\nERROR - Fixture vendor1.phone1 has issues..."
    assert_not vendor.errors[:phone2].any?, "\nERROR - Fixture vendor1.phone2 has issues..."
  end

  test "should not save a vendor with same name " do
    vendor = Vendor.new(name: vendors(:vendor1).name.upcase)
    assert vendor.invalid?, "\nERROR - Duplicate name validation is case sensitive..."
    assert vendor.errors[:name].any?
    assert_match /has already been taken/,  vendor.errors[:name].to_s
    assert_not vendor.save, "\nERROR - Your Vendor Model saved a vendor with same name.  That's not allowed..."
  end

  test "should not save a vendor with a name with spaces " do
    vendor = Vendor.new(name: "Hello No empty spaces allowed in short namemy name is Raymond", label: "Hello, it's me" )
    assert vendor.invalid?, "\nERROR - empty sapce name validation is not checking for white spaces..."
    assert vendor.errors[:name].any?
    assert_match /No empty spaces allowed in short name/,  vendor.errors[:name].to_s
    assert_not vendor.save, "\nERROR - Your Vendor Model saved a vendor with a name with spaces.  That's not allowed..."
  end

  test "should not save a vendor with a name with underscores " do
    vendor = Vendor.new(name: "Hello_i_have_underscores", label: "Hello, it's me" )
    assert vendor.invalid?, "\nERROR - underscore name validation is not checking for underscores..."
    assert vendor.errors[:name].any?
    assert_match /No underscores are allowed in short name/,  vendor.errors[:name].to_s
    assert_not vendor.save, "\nERROR - Your Vendor Model saved a vendor with underscores.  That's not allowed..."
  end


  test "should not save a name that is less than 2 character long" do
  vendor = Vendor.new(name: "H", label: "Hello, it's me" )
  assert vendor.invalid?, "\nERROR - lenght name validation is not checking for string size..."
  assert vendor.errors[:name].any?
  assert_match /is too short /,  vendor.errors[:name].to_s
  assert_not vendor.save, "\nERROR - Your Vendor Model saved a vendor with a short name of less than 2 characters.  That's not allowed..."
  end



end
