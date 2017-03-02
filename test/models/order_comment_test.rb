require 'test_helper'

class OrderCommentTest < ActiveSupport::TestCase
  setup do
    extend ActionDispatch::TestProcess
    @comment = order_comments(:one)
  end

  test "should not save an order comment if the body is blank" do
    @comment.body = nil
    assert @comment.invalid?, "\nERROR - Order comment precense validation did not work..."
    assert @comment.errors[:body].any?
    assert_match /can't be blank/,  @comment.errors[:body].to_s
    assert_not @comment.save, "\nERROR - Your Order Comment Model saved an comment and DID NOT \n" \
                            "        check the presence of an body attribute!\n"
  end

end
