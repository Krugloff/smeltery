require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  test "belongs to user" do
    assert_difference( "User.count", 1 ) { models 'comments' }
  end
end
