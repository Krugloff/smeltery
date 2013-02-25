ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # models 'comments'

  setup do
    ActiveRecord::Base.logger.debug(method_name)
  end
end
