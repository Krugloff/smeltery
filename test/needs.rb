require 'smeltery'

Smeltery::Storage.dir = "#{__dir__}/ingots"

class TestConnection
  attr_accessor :records

  def initialize
    @records = 0
  end

  def insert_fixture(columns, table_name)
    @records += 1
  end

  def clear
    @records = 0
  end
end

class TestModel
  @@last = nil
  # @connection = TestConnection.new

  def self.default_timezone
    :utc
  end

  def self.connection
    @connection ||= TestConnection.new
  end

  def self.table_name
    self.inspect
  end

  def self.last
    @@last
  end

  attr_accessor :destroyed, :invalid, :attributes

  def initialize(attributes, options)
    @attributes = { created_at: nil, updated_at: nil }.merge attributes
    @options = options
    @@last = self
  end

  def invalid?
    @destroyed = false # костыль для того чтобы считать модели сохраненными.
    @invalid
  end

  def delete
    self.class.connection.records -= 1
    @destroyed = true
  end

  def destroyed?
    @destroyed
  end
end

User = Class.new TestModel
Article = Class.new TestModel

UserComment = Class.new TestModel

Resources = Module.new
Resources::Clone = Class.new TestModel

class LibraryTest < Test::Unit::TestCase
  def self.startup
    Smeltery::Storage.cache = Array.new
    TestModel.connection.clear
    Article.connection.clear
    UserComment.connection.clear
    User.connection.clear
    Resources::Clone.connection.clear
  end
end