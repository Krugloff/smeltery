require 'smeltery'

=begin
Для обработки связей между моделями. Мне не нравится это решение, но ничего лучше я пока придумать не смог.
=end
class Smeltery::Module < Module
  def method_missing(name, *label, &block)
    name = name.to_s
    label = label.first.to_s

    # Поиск файла, соотвествующего вызываемому методу. Например `.admin_users` может ссылаться на `admin_users.rb` или `admin/users.rb`.
    until path = Dir["#{Smeltery::Storage.dir}/**/#{name}.rb"].first
      name.include?('_') ? name = name.split('_', 2).last : break
    end

    # Подразумевается, что требуемые тестовые данные должны существовать в виде экземпляров моделей, поэтому любое другое поведение, объявленное ранее, будет переопределено.
    storage = Smeltery::Storage.find_or_create(path)
    models  = Smeltery::Furnace.models( storage )
    models.value(label)
  end
end