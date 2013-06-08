require_relative 'needs'

class SmelteryTest < LibraryTest
  include Smeltery
  self.ingots_path = "#{__dir__}/ingots"
end

class ClassMethodsTest < SmelteryTest
  ingots :users
  models :user_comments

  test 'add invoice' do
    assert_equal _invoice.size, 2
  end

  test 'handle invoice' do
    assert_equal User.connection.records, 0
    assert_equal UserComment.connection.records, 1
  end

  private

    def _invoice
      self.class.invoice
    end
end

class InstanceMethodsTest < SmelteryTest
  test 'ingots' do
    ingots :users
    assert users(:admin).has_key? :name
  end

  test 'models' do
    models 'users'
    assert users(:admin).attributes.has_key? :name
  end

  test 'remove all models' do
    models :users
    assert_equal User.connection.records, 1
    remove_all_models
    assert_equal User.connection.records, 0
  end

  test 'remove all ingots' do
    models :users
    assert_equal User.connection.records, 1
    _remove_all_ingots
    assert_equal User.connection.records, 0
    assert_empty Smeltery::Storage.cache
  end

  test 'storages' do
    assert_not_empty _storages([:users])
  end

  test 'files' do
    assert_not_empty _files([:users])
  end

  test 'define accessor' do
    assert !self.respond_to?(:users)
    ingots :users
    assert self.respond_to? :users
  end

  test 'transactional' do
    assert_equal User.connection.records, 0
  end

end

class ChildTest < ClassMethodsTest
  models 'resources/clones'

  test 'add invoice' do
    assert_equal _invoice.size, 3
  end
end