#encoding: utf-8

require 'smeltery/version'
require 'smeltery/railtie' if defined?(Rails)

require 'active_support/concern'
require 'active_support/core_ext/class'
require 'active_support/core_ext/object'

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
    class_attribute :ingots_path # каталог для хранения тестовых данных.
    teardown :remove_all_models # если не используются транзакции?
  end

  module ClassMethods
    # Сохранение тестовых данных в виде моделей. Распространяется на все тесты.
    #
    # ToDo:
    # + nil для удаления предыдущих тестовых данных;
    # + повышение производительности создания моделей;
    # + на уровне класса выполнять только создание моделей, сохранение моделей выполнять отдельно для каждого теста. Это позволит быстрее отменять сделанные изменения в случае использования транзакций? или просто кешировать модели?
    def models(*names)
      return remove_all_models if names.include? nil
      setup { models(*names) }
      create_models(names)
    end

    # For DRY.
    def create_models(names)
      storages(names).map! { |ingots| Smeltery::Furnace.models(ingots) }
    end

    def remove_all_models
      Storage.cache.map! { |models| Smeltery::Furnace.ingots(models) }
    end

    # Сохранение тестовых данных в виде ассоциативных массивов. Распространяется на все тесты.
    #
    # ToDo: nil для удаления предыдущих тестовых данных.
    def ingots(*names)
      return remove_all_ingots if names.include? nil
      setup { ingots(*names) }
      create_ingots(names)
    end

    # For DRY.
    def create_ingots(names)
      storages(names).map! { |models| Smeltery::Furnace.ingots models }
    end

    def remove_all_ingots
      remove_all_models
      Storage.cache.clear
    end

    # Вынести в отдельный модуль?
    # Минимальная совместимость с rails fixtures.
    alias :fixtures :models

    def fixture_path=(path)
      self.ingots_path = path.chomp '/'
    end

    def fixture_path
      self.ingots_path
    end
    #####

    # Поиск и извлечение тестовых данных.
    #
    # ToDo: вызов ошибки, если файл не найден.
    def storages(names)
      names = names.map(&:to_s)

      Dir["#{ingots_path}/**/*.rb"].map do |path|
        unless names.include? 'all'
          next unless names.any? { |name| path.include? name }
        end

        relative_path = path.from( ingots_path.length.next )
                            .to( -File.extname(path).length.next )

        storage = Smeltery::Storage.find_or_create relative_path, path
        define_accessor storage unless method_defined? storage.type
        storage
      end
    end

    # Идентификатор метода вычисляется с помощью имени файла.
    def define_accessor(storage)
      define_method(storage.type) { |label| storage.value(label) }
    end


  end

  # Сохранение тестовых данных в виде ассоциативных массивов. Распространяется только на текущий тест.
  def ingots(*names)
    return remove_all_ingots if names.include? nil
    self.class.create_ingots(names)
  end

  # Сохранение тестовых данных в виде моделей. Распространяется только на текущий тест.
  def models(*names)
    return remove_all_models if names.include? nil
    self.class.create_models(names)
  end

  # Используется для отмены изменений, сделанных тестом. Стоит заметить, что добавление новых тестовых данных не отменяется - с этого момента они будут существовать для всех тестов (в виде ассоциативных массивов).
  #
  # Достоинства:
  # + довольно легко удалять любые изменения.
  # Недостатки:
  # + Фактически требуемые модели создаются заново для каждого теста. Необходимо увеличить скорость создания моделей.
  def remove_all_models
    self.class.remove_all_models
  end

  def remove_all_ingots
    self.class.remove_all_ingots
  end
end