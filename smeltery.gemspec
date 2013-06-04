Gem::Specification.new do |spec|
  spec.name          = 'smeltery'
  spec.version       = '0.2.5'
  spec.summary       = %{Simple organizing test data in ActiveRecord.}
  spec.description   = %{Smeltery allow organize test data in Ruby files as instance variables associated with attribute's hash.}

  spec.author        = 'Krugloff'
  spec.email         = 'mr.krugloff@gmail.com'
  spec.license       = 'MIT'
  spec.homepage      = 'http://github.com/Krugloff/smeltery'

  spec.files         = Dir["{lib,test}/**/*", "[A-Z]*"]
  spec.test_files    = 'test'
  spec.require_path  = 'lib'

  spec.add_dependency( 'activesupport', '>= 3.2' )
end