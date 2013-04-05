require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  models('comments')

  test "belongs to user" do
    assert respond_to?('comments'), Comment.count.to_s
    assert !respond_to?('users')
    assert comments('valid').user.persisted?
  end

  test 'user must be persisted' do
    assert comments('valid').user.persisted?
  end

  test 'deleted user' do
    ingots :users
    assert_nil comments('valid').user
    assert comments('valid').user_id
  end

  test 'symbolic labels' do
    ingots :users
    assert_nil comments(:valid).user
    assert comments(:valid).user_id
  end
end
