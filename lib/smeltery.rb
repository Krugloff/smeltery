#encoding: utf-8

require 'smeltery/version'
require 'smeltery/rails/railtie' if defined?(Rails)
require 'smeltery/rails/transactional_tests' if defined?(ActiveRecord)

require 'active_support/concern'
require 'active_support/core_ext/class'
require 'active_support/core_ext/object'
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

  extend ActiveSupport::Concern

  included do
    # ToDo: rails fixtures
    # + table_names
    # + class_names

    include TransactionalTests

    cattr_accessor :ingots_path # каталог для хранения тестовых данных.
    cattr_accessor(:invoice) { HashWithIndifferentAccess.new }

    setup :handle_invoice
    teardown :remove_all_models
  end

  module ClassMethods
    # Сохранение тестовых данных в виде моделей. Распространяется на все тесты. (см. handle_invoice)
    def models(*names)
      names.each { |name| invoice[name] = proc { models(name) } }
    end

    # Сохранение тестовых данных в виде ассоциативных массивов. Распространяется на все тесты (см. handle_invoice).
    def ingots(*names)
      names.each { |name| invoice[name] = proc { ingots(name) } }
    end

    # Минимальная совместимость с rails fixtures.
    alias fixtures models

    def fixture_path=(path)
      self.ingots_path = path.chomp '/'
    end

    def fixture_path
      self.ingots_path
    end
    #####
  end

  # Сохранение тестовых данных в виде ассоциативных массивов. Распространяется только на текущий тест.
  def ingots(*names)
    return _remove_all_ingots if names.include? nil
    _storages(names).map! { |models| Furnace.ingots(models) }

    rescue NoMethodError => method
      _association method
  end

  # Сохранение тестовых данных в виде моделей. Распространяется только на текущий тест.
  def models(*names)
    return remove_all_models if names.include? nil
    _storages(names).map! { |ingots| Furnace.models(ingots) }

    rescue NoMethodError => method
      _association method
  end

  alias fixtures models

  private

    # Инициализация требуемых тестовых данных.
    def handle_invoice
      invoice.values.each(&:call)
    end

    # Отмена изменений тестовых данных. В данном случае скорость принесена в жертву удобству.
    def remove_all_models
      Storage.cache.map! { |models| Furnace.ingots(models) }
    end

    def _remove_all_ingots
      remove_all_models
      Storage.cache.clear
    end

    def _storages(names)
      names = names.map(&:to_s)

      Dir["#{ingots_path}/**/*.rb"].map do |path|
        # Delete this line?
        next nil unless File.file? path

        relative_path = path.from( ingots_path.length.next )
                            .to( -File.extname(path).length.next )

        unless names.include? 'all'
          # ToDo: File.basename(relative_path, File.extname(relative_path)) == name
          next nil unless names.any? { |name| path.include? name }
        end

        storage = Storage.find_or_create relative_path, path
        _define_accessor storage unless respond_to? storage.type
        storage
      end.compact
    end

    # Идентификатор метода вычисляется с помощью расположения файла.
    def _define_accessor(storage)
      define_singleton_method(storage.type) { |label| storage.value(label) }
    end

    # Инициализация тестовых данных, необходимых для реализации связей между моделями. Для реализаци связи в любом случае будут созданы экземпляры модели (даже для тестовых данных, представленных в виде ассоциативного массива). Это поведение может измениться в дальнейшем.
    def _association(method)
      name = method.name.to_s
      while models(name).empty? && name.include?('_')
        name = name.split('_', 2).last
      end
      self.send(method.name, method.args.first)
    end
end