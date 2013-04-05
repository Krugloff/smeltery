#encoding: utf-8

# Представление тестовых данных в виде экземпляра модели. Сохранение экземпляров выполняется отдельно.
class Smeltery::Furnace::Model
  def self.create(klass, ingot)
    new(klass, ingot).tap { |model| model.cool }
  end

  def initialize(klass, ingot)
    @label = ingot.label
    @ingot = ingot
    @klass = klass

    @model = @ingot.respond_to?(:to_model) ?
      @ingot.to_model :
      @klass.new( @ingot.value, without_protection: true )
  end

  attr_reader :label, :value

  # Сохранение модели. Тестовые данные, не прошедшие проверку, будут представлены не сохраненным экземпляром модели.
  def cool
    return @value = @model if @model.invalid?

    now = (@klass.default_timezone == :utc ? Time.now.utc : Time.now)
      .to_s(:db)
    columns = @model.attributes
    columns['created_at'] = now unless columns['created_at']
    columns['updated_at'] = now unless columns['updated_at']

    @klass.connection.insert_fixture columns, @klass.table_name
    @value = @klass.last # danger!
  end

  # Удаление модели.
  def to_ingot
    @value.delete if @value
    model = @model
    @ingot.define_singleton_method(:to_model) do
      # self.values.find
      # Найти ключи, ассоциированные с несохраненными моделями.
      # И преобразовать соответствующие тестовые данные в модели.
      # А затем извлечь необходимую модель.
      ingot = self.value

      keys = ingot.keys.select do |key|
        ingot[key].respond_to?(:destroyed?) && ingot[key].destroyed?
      end

      # Rails.logger.debug(keys.inspect)
      keys.each do |key|
        Smeltery::Module.models(key)#.find { |model| model.value.id =  }
        # Rails.logger.debug ingot[key].inspect
      end

      model
    end
    @ingot
  end

  def inspect
    @value ? @value.inspect : @ingot.inspect
  end
end