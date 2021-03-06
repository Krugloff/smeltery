# Smeltery

Библиотека позволяет управлять данными, используемыми для тестирования.

Данные хранятся в обычных Ruby-файлах (имя файла зависит от названия модели) в виде переменных экземпляра, ссылающихся на ассоциативные массивы. Массивы содержат набор свойств для отдельных экземпляров модели.

## Installation

Add this line to your application's Gemfile:

    gem 'smeltery', git: 'http://github.com/Krugloff/smeltery.git'

And then execute:

    $ bundle

## Usage

### Условия использования

+ добавление модуля;
+ определение каталога, в котором хранятся тестовые данные;
+ инициализация тестовых данных в виде ассоциативных массивов или моделей;
+ использование тестовых данных с помощью предоставленных методов доступа.


Если вы используете Rails, то все эти действия уже выполнены по умолчанию для класса ActiveSupport::TestCase.

```ruby
  class ActiveSupport::TestCase
    include Smeltery
  end
  ActiveSupport::TestCase.fixture_path = 'test/fixtures/'
```

#### Каталог

Для совместимости с rails fixtures, по умолчанию, тестовые данные находятся в каталоге test/fixtures приложения.

Чтобы изменить поведение по умолчанию могут быть использованы свойства класса `fixture_path` и `ingots_path`.

#### Инициализация

`::models(*names)`  
Синонимы: fixtures  
Объявление тестовых данных, которые будут представлены экземплярами моделей.

`::ingots(*names)`  
Объявление тестовых данных, которые будут представлены ассоциативными массивами.

+ В качестве аргументов, методы принимают нормализованные имена файлов, содержащих тестовые данные: 'users', 'user_admins' и т.д.;

+ Чтобы использовать все тестовые данные методам передается `:all`:  
`models :all`;

+ Чтобы удалить все модели или вообще все тестовые данные в качестве аргумента передается nil;

+ Вместо методов класса, влияющих на выполнение всех тестов, могут использоваться методы экземпляров, влияющие на выполнение только текущего теста.

##### Сохранение моделей

При сохранении моделей выполняется только проверка сохраняемых данных. Для данных, не прошедших проверку, экземпляры моделей создаются, но не сохраняются.

#### Методы доступа

Любые тестовые данные могут быть получены с помощью методов экземпляров вида: `.name(label)`, где name зависит от расположения файла с тестовыми данными, а label от имени переменной экземпляра.

```ruby
  class UserTest < ActiveSupport::TestCase
    models 'users'

    test 'update' do
      assert users('mike').update_attribute name: 'Mikky'
    end

    test 'create' do
      ingots 'users'
      assert User.create users('mike')
    end
  end
```

### Формат тестовых данных

Для каждой модели создается отдельный файл (*.rb) с тестовыми данными. Имя и расположение файла взаимосвязаны с названием модели.

Пример файла с описанием экземпляров модели User:
```ruby
  # test/ingots/users.rb
  @krugloff = { name: 'Krugloff',
                password: 'a11ri9ht' }
  @mike     = @krugloff.merge name: 'Mike'
  @john     = @krugloff.merge name: 'John'
  @hacker   = @krugloff.merge password: 'fail'
```

#### Связь с другими моделями

Для присоединения ассоциируемых объектов могут использоваться тестовые данные (с помощью методов доступа). В этом случае всегда будет создан экземпляр модели (даже для тестовых данных представленных в виде ассоциативного массива).

```ruby
  # test/ingots/comments.rb
  @welcome = { title: 'Welcome',
               body: 'Welcome to my blog!',
               user: users('krugloff') }
```

Осторожно! Преобразование тестовых данных в ассоциативные массивы может привести к удалению ассоциируемой модели. В этом случае для модели будет существовать только внешний ключ (например user_id).
```ruby
  # Тестовые данные
  @valid =  { title: 'Welcome',
              body: 'Welcome to my blog!',
              user: users('krugloff') }

  # Тест
  class CommentTest < ActiveSupport::TestCase
    models('comments')

    test "belongs to user" do
      assert respond_to?('comments'), Comment.count.to_s
      assert !respond_to?('users')
      assert comments('valid').user.persisted?
    end

    test 'user must be persisted' do
      ingots :users
      assert_nil comments('valid').user # -> true
      assert comments('valid').user_id # -> true
    end
  end
```

Осторожно! Рекурсивный вызов тестовых данных может привести к бесконечному циклу.

### Транзакции

По умолчанию тесты выполняются в составе отдельных транзакций. Тесты, реализующие транзакции самостоятельно, должны быть объявлены в явной форме с помощью `::uses_transaction(*methods)`.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
