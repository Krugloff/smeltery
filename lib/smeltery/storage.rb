# encoding: utf-8

require 'active_support/core_ext/string'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/class/attribute_accessors'

# Хранение тестовых данных в любой форме.
class Smeltery::Storage < Array
  autoload 'Ingot', 'smeltery/storage/ingot'

  class_attribute 'cache'
  self.cache = Array.new

  cattr_accessor 'dir'

  # Кеширование уже обработанных хранилищ.
  def self.find_or_create(path)
    a_storage = cache.find { |storage| storage.path == path }
    unless a_storage
      a_storage = new(path).ingots
      cache << a_storage
    end
    a_storage
  end

  def initialize(path)
    @path = path
    @relative_path =  path.from( dir.length.next )
                          .to( -File.extname(path).length.next )

    @type = @relative_path.tr('/', '_')
    @content = File.read(path)
    super()
  end

  attr_reader :type, :path

  # Вычисление тестовых данных. На данный момент поддерживается только один формат:
  # @krugloff = { name: 'Krugloff',
  #               password: 'secure' }

  # @john     = { name: 'John',
  #               password: 'secure' }
  def ingots
    ingots = Smeltery::Module.new
    ingots.module_eval @content

    ingots.instance_variables.each_with_object(self) do |var, buffer|
      label = var.to_s.delete '@'
      value = ingots.instance_variable_get(var)
      buffer << Ingot.new(label, value)
    end
  end

  # Поиск объекта по метке.
  def value(label)
    find { |el| el.label == label }.value
  end

  def model_klass
    @relative_path.classify.constantize
  end
end