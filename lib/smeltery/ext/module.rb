require 'smeltery'

=begin
Для обработки связей между моделями. Мне не нравится это решение, но ничего лучше я пока придумать не смог.

Для реализаци связи в любом случае будут созданы экземпляры модели (даже для тестовых данных, представленных в виде ассоциативного массива). Это поведение может измениться в дальнейшем.
=end
class Smeltery::Module < Module
  def method_missing(name, *label, &block)
    # ToDo: Исключение?
    # return if label.many? || block_given

    name = name.to_s
    label = label.first.to_s
    User.first

    # Поиск файла, соотвествующего вызываемому методу. Например `.admin_users` может ссылаться на `admin_users.rb` или `admin/users.rb`.
    # while Smeltery.models(name).empty? && name.include?('_')
    #   name = name.split('_', 2).last
    # end
    # Smeltery.models(name).value(label)
    # Smeltery.send(name, label)
  end
end