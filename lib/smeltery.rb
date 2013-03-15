#encoding: utf-8

require 'smeltery/version'
require 'smeltery/rails/railtie' if defined?(Rails)
require 'smeltery/rails/transactional_tests' if defined?(ActiveRecord)
require 'smeltery/ext/module'

require 'active_support/concern'
require 'active_support/core_ext/class/attribute'
require 'active_support/hash_with_indifferent_access'

=begin
  Управление созданием моделей на основе тестовых данных.

  Use:
  + добавление модуля;
  + определение каталога, в котором хранятся тестовые данные;
  + инициализация тестовых данных в виде ассоциативных массивов или моделей;
  + использование тестовых данных с помощью предоставленных методов доступа.

  ```ruby
    class ActiveSupport::TestCase
      include Smeltery
    end
    ActiveSupport::TestCase.ingots_path = 'test/ingots'
  ```
=end
module Smeltery
  autoload 'Storage', 'smeltery/storage'
  autoload 'Furnace', 'smeltery/furnace'

  # для обработки связей с другими моделями.
  autoload 'Module', 'smeltery/ext/module'

  extend ActiveSupport::Concern
  include TransactionalTests if defined? TransactionalTests

  module ClassMethods
    # Объявление тестовых данных, необходимых в виде ассоциативных массивов. Распространяется на все тесты. (см. handle_invoice).
    def ingots(*names)
      names.each { |name| invoice[name] = proc { ingots(name) } }
    end

    # Объявление тестовых данных, необходимых в виде моделей. Распространяется на все тесты. (см. handle_invoice).
    def models(*names)
      names.each { |name| invoice[name] = proc { models(name) } }
    end

    # Изменения, внесенные одним из наследников не должны влиять на других наследников или базовый класс -> поведение констант.
    def invoice
      @invoice ||= superclass.invoice.dup rescue HashWithIndifferentAccess.new
    end

    # Минимальная совместимость с rails fixtures.
    alias fixtures models

    def fixture_path=(path)
      self.ingots_path = path.chomp '/'
    end

    def fixture_path
      ingots_path
    end
    #####
  end

  included do
    class_attribute :ingots_path
    self.ingots_path = 'test/ingots'

    setup :handle_invoice
    teardown :remove_all_models
  end

  private

    # Инициализация требуемых тестовых данных.
    def handle_invoice
      self.class.invoice.values.each { |task| self.instance_exec(&task) }
    end

    # Сохранение тестовых данных в виде ассоциативных массивов. Распространяется только на текущий тест.
    def ingots(*names)
      return _remove_all_ingots if names.include? nil
      _storages(names).each { |models| Furnace.ingots(models) }
    end

    # Сохранение тестовых данных в виде моделей. Распространяется только на текущий тест.
    def models(*names)
      return remove_all_models if names.include? nil
      _storages(names).each { |ingots| Furnace.models(ingots) }
    end
    alias fixtures models

    # Отмена изменений тестовых данных. В данном случае скорость принесена в жертву удобству.
    def remove_all_models
      Storage.cache.each { |models| Furnace.ingots(models) }
    end

    def _remove_all_ingots
      remove_all_models
      Storage.cache.clear
    end

    def _storages(names)
      Storage.dir = ingots_path

      _files(names).map do |path|
        storage = Storage.find_or_create(path)
        _define_accessor storage unless respond_to? storage.type
        storage
      end
    end

    def _files(names)
      names = names.map(&:to_s)
      names = names.include?('all') ? '*' : names.join(',')
      Dir["#{ingots_path}/**/{#{names}}.rb"]
    end

    # Идентификатор метода вычисляется с помощью расположения файла.
    def _define_accessor(storage)
      define_singleton_method(storage.type) { |label| storage.value(label) }
    end
end