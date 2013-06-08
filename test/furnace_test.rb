require_relative 'needs'

class FurnaceTest < LibraryTest
  setup do
    @storage = Smeltery::Storage.new("#{__dir__}/ingots/users.rb").ingots
  end

  test 'models' do
    before = @storage.last
    Smeltery::Furnace.models(@storage)
    assert_not_equal before, @storage.last
    assert_equal @storage.last.class, Smeltery::Furnace::Model

    before = @storage.last
    Smeltery::Furnace.models(@storage)
    assert_equal before, @storage.last
  end

  test 'ingots' do
    before = @storage.last
    Smeltery::Furnace.ingots(@storage)
    assert_equal before, @storage.last

    before = @storage.last
    Smeltery::Furnace.models(@storage)
    Smeltery::Furnace.ingots(@storage)
    assert_equal before, @storage.last
  end
end