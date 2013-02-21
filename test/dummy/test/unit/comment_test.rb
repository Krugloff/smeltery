require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  test "belongs to user" do
    models('comments')
    models('users')
    assert comments('welcome').user == users('krugloff')
  end
end
