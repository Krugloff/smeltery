#encoding: utf-8

require 'smeltery/version'
require 'smeltery/rails/railtie' if defined?(Rails)
require 'smeltery/rails/transactional_tests' if defined?(ActiveRecord)
require 'smeltery/ext/module'

require 'active_support/concern'
require 'active_support/core_ext/class/attribute_accessors'
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
  # include TransactionalTests if defined? TransactionalTests

  module ClassMethods
    # Объявление тестовых данных, необходимых в виде ассоциативных массивов. Распространяется на все тесты. (см. handle_invoice).
    def ingots(*names)
      names.each { |name| invoice[name] = proc { ingots(name) } }
      # Объявлять методы доступа здесь?
    end

    # Объявление тестовых данных, необходимых в виде моделей. Распространяется на все тесты. (см. handle_invoice).
    def models(*names)
      names.each { |name| invoice[name] = proc { models(name) } }
      # Объявлять методы доступа здесь?
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
    # ToDo: rails fixtures
    # + table_names
    # + class_names

    class_attribute :ingots_path
    self.ingots_path = 'test/ingots'

    class_attribute :invoice
    self.invoice = HashWithIndifferentAccess.new

    setup :handle_invoice
    teardown :remove_all_models

    include TransactionalTests if defined? TransactionalTests
  end

  private

    # Инициализация требуемых тестовых данных.
    def handle_invoice
      ActiveRecord::Base.logger.debug invoice.to_s
      invoice.values.each { |task| self.instance_eval task }
    end

    # Сохранение тестовых данных в виде ассоциативных массивов. Распространяется только на текущий тест.
    def ingots(*names)
      return _remove_all_ingots if names.include? nil
      _storages(names).each { |models| Furnace.ingots(models) }
    end

    # Сохранение тестовых данных в виде моделей. Распространяется только на текущий тест.
    def models(*names)
      ActiveRecord::Base.logger.debug 'Models:' + names.join(',')
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
      _files(names).map do |path|
        ActiveRecord::Base.logger.debug path
        relative_path = path.from( ingots_path.length.next )
                            .to( -File.extname(path).length.next )

        storage = Storage.find_or_create relative_path, path
        _define_accessor storage unless respond_to? storage.type
        storage
      end
    end

    def _files(names)
      names = names.map(&:to_s)
      ActiveRecord::Base.logger.debug names.join(',')
      names = names.include?('all') ? '*' : names.join(',')
      Dir["#{ingots_path}/**/#{names}.rb"]
    end

    # Идентификатор метода вычисляется с помощью расположения файла.
    def _define_accessor(storage)
      define_singleton_method(storage.type) { |label| storage.value(label) }
    end

  # Позволяет управлять тестовыми данными непосредственно с помощью модуля. Используется для реализации связей между моделями.
  # module_function 'ingots',
  #                 'models',
  #                 'remove_all_models',
  #                 '_remove_all_ingots',
  #                 '_storages',
  #                 '_files',
  #                 '_define_accessor'
end