# encoding: utf-8

require 'active_support/core_ext/string'
require 'active_support/core_ext/class'

# Хранение тестовых данных в любой форме.
class Smeltery::Storage < Array
  autoload 'Ingot', 'smeltery/storage/ingot'

  # Кеширование уже обработанных хранилищ.
  def self.find_or_create(relative_path, path)
    @cache ||= []
    cache = @cache.find { |storage| storage.path == relative_path }
    unless cache
      cache = new( relative_path, File.read(path) ).ingots
      @cache << cache
    end
    cache
  end

  def self.cache
    @cache || []
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
    ingots = Module.new
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