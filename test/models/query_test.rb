require 'test_helper'

class QueryTest < ActiveSupport::TestCase
  setup do
    @query1 = queries(:one)
  end

  test "should not save a query without a description " do
    @query1.description = nil
    @query1.save
    assert @query1.errors[:description].any?
    assert_match /can't be blank/,  @query1.errors[:description].to_s
    assert_not @query1.save, "\nERROR - Your Query Model saved a query without a description.  That's not allowed..."
  end

  test "should not save a query without a sql " do
    @query1.sql = nil
    @query1.save
    assert @query1.errors[:sql].any?
    assert_match /can't be blank/,  @query1.errors[:sql].to_s
    assert_not @query1.save, "\nERROR - Your Query Model saved a query without a sql option.  That's not allowed..."
  end

  test "should not save a query without a name " do
    @query1.name = nil
    @query1.save
    assert @query1.errors[:name].any?
    assert_match /can't be blank/,  @query1.errors[:name].to_s
    assert_not @query1.save, "\nERROR - Your Query Model saved a query without a name.  That's not allowed..."
  end

  test "should not save a query without a label " do
    @query1.label = nil
    @query1.save
    assert @query1.errors[:label].any?
    assert_match /can't be blank/,  @query1.errors[:label].to_s
    assert_not @query1.save, "\nERROR - Your Query Model saved a query without a label.  That's not allowed..."
  end

  test "should not save a query without the same amount of binding conditions to ? added to sql attribute " do
    @query1.sql = 'bottles where units = ? and qty_available_mg_ul > ?'
    @query1.conditions = ''
    @query1.save
    assert @query1.errors[:conditions].any?
    assert_match /Incorrect number of conditions/,  @query1.errors[:conditions].to_s
    assert_not @query1.save, "\nERROR - Your Query Model saved a query without the correct number of arguments.  That's not allowed..."
  end

  test "test can not save an invalid sql statement" do
    @query1.sql = 'bottles where moms dad and all of my stupid siblings'
    @query1.save
    assert @query1.errors[:sql].any?
    assert_match /Mysql2::Error/,  @query1.errors[:sql].to_s
    assert_not @query1.save, "\nERROR - Your Query Model saved a query with an incorrect sql statement.  That's not allowed..."
  end

  test "test can not allow certain characters to be in sql statement" do
    @query1.sql = 'bottles; DROP TABLE users'
    @query1.save
    assert @query1.errors[:sql].any?
    assert_match /SQL contiains illegal characters /,  @query1.errors[:sql].to_s
    assert_not @query1.save, "\nERROR - Your Query Model saved a query with illegal characters.  That's not allowed..."
  end

end
