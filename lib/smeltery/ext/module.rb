require 'smeltery'

=begin
Для обработки связей между моделями. Мне не нравится это решение, но ничего лучше я пока придумать не смог.
=end
class Smeltery::Module < Module
  def self.models(name)
    name = name.to_s.pluralize
    # Поиск файла, соотвествующего вызываемому методу. Например `.admin_users` может ссылаться на `admin_users.rb` или `admin/users.rb`.
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
end