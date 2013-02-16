#encoding: utf-8

# Получение тестовых данных в необходимом виде.
module Smeltery::Furnace
  autoload 'Model', 'smeltery/furnace/model'

  def self.models(ingots)
    ingots.map! do |ingot|
      case
      when (defined? Model) && ingot.is_a?(Model)
        ingot
      when ingot.respond_to?(:to_model)
        ingot.to_model
      else
        Model.create( ingots.model_klass, ingot )
      end
    end
  end

  def self.ingots(models)
    models.map! do |model|
      model.respond_to?('to_ingot') ? model.to_ingot : model
    end
  end
end