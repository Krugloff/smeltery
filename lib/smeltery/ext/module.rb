=begin
Для обработки связей между моделями. Мне не нравится это решение, но ничего лучше я пока придумать не смог.
=end
module Smeltery class Module < Module
  def self.models(name)
    name = name.to_s.pluralize
    # Поиск файла, соотвествующего вызываемому методу. Например `.user_comments` может ссылаться на `user_comments.rb` или `user/comments.rb`.
    until path = Dir["#{Smeltery::Storage.dir}/**/#{name}.rb"].first
      name.include?('_') ? name = name.split('_', 2).last : break
    end

    # Подразумевается, что требуемые тестовые данные должны существовать в виде экземпляров моделей, поэтому любое другое поведение, объявленное ранее, будет переопределено.
    Smeltery::Furnace.models Smeltery::Storage.find_or_create(path)
  end

  def method_missing(name, *label, &block)
    label = label.first.to_s
    self.class.models(name).value(label)
  end
end end