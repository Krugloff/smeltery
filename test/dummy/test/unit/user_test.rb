# require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'without test data' do
    message = "Users: " + User.count.to_s
    assert( User.count == 0 , message )
    assert_raise(NoMethodError) { users('krugloff') }
  end

  # Если не отменить изменения, сделанные в этом тесте, то предыдущий тест будет провален. Тест используется для проверки работы транзакций.
  test 'save new user' do
    user = User.new name: 'mike'
    user.password = 'dreams'
    user.save
  end

  test 'create ingots' do
    ingots 'users'
    assert users('krugloff')
  end

  test 'create models' do
    assert_difference( "User.count", 1 ) { models 'users' }
  end

  test 'create model from ingots' do
    ingots 'users'
    assert_difference( "User.count", 1 ) { models 'users' }
    assert users('krugloff').persisted?
  end

  test 'delete models' do
    models('users')
    assert_difference( "User.count", -1 ) { ingots 'users' }
  end

  test 'cache models' do
    models 'users'
    assert_no_difference("User.count") { models 'users' }
  end

  test 'cache ingots' do
    ingots('users').equal? ingots('users')
  end

  test 'invalid model' do
    models 'users'
    assert users('hacker').invalid?
  end

  test 'delete all models' do
    models 'users'
    assert User.count > 0

    models(nil)
    message = "Users: " + User.count.to_s
    assert( User.count == 0, message )
  end

  # test 'associations' do
    
  # end

  # test 'ingots not found' do
  #   ingots 'hacker'
  # end
end
