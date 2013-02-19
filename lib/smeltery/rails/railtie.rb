module Smeltery class Railtie < Rails::Railtie
  # TestFixtures included to ActiveSupport::TestCase in 'rails/test_help'
  initializer 'smeltery.replace_test_fixtures' do
    ActiveRecord.autoload :TestFixtures, 'smeltery'
    ActiveRecord::TestFixtures = Smeltery
  end
end end