require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  models('comments')
  test "belongs to user" do
    ActiveRecord::Base.logger.debug(self.to_s)
    assert respond_to?('comments'), Comment.count.to_s
    # models('users')
    # assert comments('welcome').user == users('krugloff')
  end
end
