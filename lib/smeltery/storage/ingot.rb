#encoding: utf-8

# Представление тестовых данных в виде ассоцитивного массива. Используется по умолчанию.
class Smeltery::Storage::Ingot
  def initialize(label, value)
    @label = label
    @value = value
  end

  attr_reader :label, :value

  def inspect
    @value.inspect
  end
end