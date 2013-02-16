lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'smeltery/version'

Gem::Specification.new do |gem|
  gem.name          = "smeltery"
  gem.version       = Smeltery::VERSION
  gem.authors       = ["Krugloff"]
  gem.email         = ["mr.krugloff@gmail.com"]
  gem.description   = "Smeltery allow organize test data in Ruby files as instance variables associated with attribute's hash"
  gem.summary       = 'Simple organizing test data in ActiveRecord'
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  # gem.add_dependency( 'activerecord', '>=3.2.11' )
  gem.add_dependency( 'activesupport', '>= 3.2' )
end
