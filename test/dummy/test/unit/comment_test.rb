require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  models('comments')

  test "belongs to user" do
    assert respond_to?('comments'), Comment.count.to_s
    assert !respond_to?('users')
    assert comments('valid').user.persisted?
  end
end
