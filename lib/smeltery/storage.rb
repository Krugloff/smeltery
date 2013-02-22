# encoding: utf-8

require 'active_support/core_ext/string'
require 'active_support/core_ext/class/attribute_accessors'

# Хранение тестовых данных в любой форме.
class Smeltery::Storage < Array
  autoload 'Ingot', 'smeltery/storage/ingot'

  # для обработки связей с другими моделями.
  # autoload 'Module', 'smeltery/ext/module'

  cattr_accessor('cache') { Array.new }

  # Кеширование уже обработанных хранилищ.
  def self.find_or_create(relative_path, path)
    a_storage = @@cache.find { |storage| storage.path == relative_path }
    unless a_storage
      a_storage = new( relative_path, File.read(path) ).ingots
      # type = a_storage.type
      # define_singleton_method(type) { a_storage } unless respond_to? type
      @@cache << a_storage
    end
    a_storage
  end

  def initialize(path, content)
    @path = path
    @type = @path.tr('/', '_')
    @content = content
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
    @path.classify.constantize
  end
end