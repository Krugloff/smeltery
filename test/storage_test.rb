require_relative 'needs'

class StorageTest < LibraryTest
  setup do
    @users = Smeltery::Storage.new "#{__dir__}/ingots/users.rb"
    @comments =
      Smeltery::Storage.new("#{__dir__}/ingots/user_comments.rb")
    @clones = Smeltery::Storage.new("#{__dir__}/ingots/resources/clones.rb")
  end

  test 'cache' do
    assert_empty Smeltery::Storage.cache

    @users = Smeltery::Storage.find_or_create "#{__dir__}/ingots/users.rb"
    assert_not_empty Smeltery::Storage.cache
    assert_equal Smeltery::Storage.cache.last, @users

    before = Smeltery::Storage.cache.size
    Smeltery::Storage.find_or_create "#{__dir__}/ingots/users.rb"
    assert_equal before, Smeltery::Storage.cache.size
    assert_equal Smeltery::Storage.cache.last, @users
  end

  test 'users' do
    assert_empty @users

    @users.ingots

    assert_not_empty @users
    assert @users.value(:admin).has_key? :name
    assert_equal @users.model_klass, User

  end

  test 'user comments' do
    assert_empty @comments

    @comments.ingots

    assert_not_empty @comments
    assert @comments.value(:valid).has_key? :body
    assert_equal @comments.model_klass, UserComment
  end

  test 'resources clones' do
    assert_empty @clones

    @clones.ingots

    assert_not_empty @clones
    assert @clones.value(:luke).has_key? :name
    assert_equal @clones.model_klass, Resources::Clone
  end
end