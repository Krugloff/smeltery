#encoding: utf-8

# Представление тестовых данных в виде экземпляра модели. Сохранение экземпляров выполняется отдельно.
class Smeltery::Furnace::Model
  def self.create(klass, ingot)
    new(klass, ingot).tap { |form| form.cool }
  end

  def initialize(klass, ingot)
    @label = ingot.label
    @ingot = ingot
    @klass = klass
    @value = @klass.new @ingot.value, without_protection: true
  end

  # Для данных, не прошедших проверку, значением будет экземпляр модели.
  attr_reader :label, :value

  # Сохранение модели.
  #
  # ToDo: сохранение модели таким образом приводит к созданию транзакций. Чтобы избежать этого надо сохранять модель без участия метода save, а с помощью insert_fixture:
  # + необходимо проверять соответствие модели тербованиям;
  # + это также позволит игнорировать обработку жизненного цикла.
  def cool
    # return if @value.invalid?

    # now = (@klass.default_timezone == :utc ? Time.now.utc : Time.now)
    #   .to_s(:db)
    # columns = @value.attributes
    # columns['created_at'] = now unless columns['created_at']
    # columns['updated_at'] = now unless columns['updated_at']

    # @klass.connection.insert_fixture columns, @klass.table_name
    # @value = @klass.last
    @value.save
  end

  # Удаление модели.
  #
  # ToDo: возможно стоит определить собственный метод для возвращаемого объекта, с помощью которого будут кешированы модели?
  def to_ingot
    @value.delete
    @ingot #.tap { |ingot| ingot.define_singleton_method(:to_model) {@model} }
  end

  def inspect
    @value ? @value.inspect : @ingot.inspect
  end
end