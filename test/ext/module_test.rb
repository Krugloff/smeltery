require_relative '../needs'

class ModuleTest < LibraryTest
  setup do
    @before = Smeltery::Storage.cache.size
  end

  teardown do
    Smeltery::Storage.cache = Array.new
  end

  test 'users' do
    models = Smeltery::Module.models(:users)
    assert @before < Smeltery::Storage.cache.size
    assert_equal models.last.class, Smeltery::Furnace::Model
  end

  test 'user comments' do
    models = Smeltery::Module.models(:user_comments)
    assert @before < Smeltery::Storage.cache.size
    assert_equal models.last.class, Smeltery::Furnace::Model
  end

  test 'resources clones' do
    models = Smeltery::Module.models(:resources_clones)
    assert @before < Smeltery::Storage.cache.size
    assert_equal models.last.class, Smeltery::Furnace::Model
  end

  test 'method missing' do
    model = Smeltery::Module.new.users(:admin)
    assert_equal model.class, User
  end
end