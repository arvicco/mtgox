# encoding: utf-8
require File.expand_path('../lib/mtgox/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors      = ["Erik Michaels-Ober", "arvicco"]
  gem.description = "Ruby wrapper for the Mt. Gox Trade API. Extended with Models."
  gem.email       = 'arvicco@gmail.com'
  gem.files       = `git ls-files`.split("\n")
  gem.homepage    = 'https://github.com/arvicco/mtgox'
  gem.name        = 'mt_gox'
  gem.require_paths = ['lib']
  gem.required_ruby_version = '>= 1.9.2'
  gem.summary     = "Ruby wrapper for the Mt. Gox Trade API."
  gem.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.version     = MtGox::VERSION

  gem.add_dependency 'faraday', '~> 0.7'
  gem.add_dependency 'faraday_middleware', '~> 0.7'
  gem.add_dependency 'multi_json', '~> 1.0'
  gem.add_development_dependency 'json'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rdiscount'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'webmock'
  gem.add_development_dependency 'yard'

end
