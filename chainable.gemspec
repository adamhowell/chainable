# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = 'chainable'
  spec.version       = '0.3.0'
  spec.authors       = ['adamhowell', 'Adam Howell']
  spec.description   = %q{Track consecutive day chains on Rails/ActiveRecord models.}
  spec.summary       = %q{Easily track consecutive day chains on your Rails/ActiveRecord model associations for a given date column.}
  spec.homepage      = 'https://github.com/adamhowell/chainable/'
  spec.license       = 'MIT'
  spec.metadata = {
    "source_code_uri"   => "https://github.com/adamhowell/chainable/",
  }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activerecord', '>= 3.2.22'

  spec.add_development_dependency 'appraisal'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'timecop'
  spec.add_development_dependency 'activesupport'
  spec.add_development_dependency 'pry-coolline'
end
