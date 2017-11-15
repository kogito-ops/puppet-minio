source 'https://rubygems.org'

gem 'rubocop', '>= 0.49.1'

group :test do
  gem 'json_pure', '<= 2.0.1',                                          require: false if RUBY_VERSION < '2.0.0'
  gem 'metadata-json-lint',                                             require: false
  gem 'mocha', '>= 1.2.1',                                              require: false
  gem 'puppet-blacksmith', '>= 3.4.0',                                  require: false
  gem 'puppet-lint-absolute_classname-check',                           require: false
  gem 'puppet-lint-classes_and_types_beginning_with_digits-check',      require: false
  gem 'puppet-lint-leading_zero-check',                                 require: false
  gem 'puppet-lint-trailing_comma-check',                               require: false
  gem 'puppet-lint-unquoted_string-check',                              require: false
  gem 'puppet-lint-variable_contains_upcase',                           require: false
  gem 'puppet-lint-version_comparison-check',                           require: false
  gem 'puppetlabs_spec_helper', '~> 1.2.2',                             require: false
  gem 'rspec-puppet', '~> 2.5',                                         require: false
  gem 'rspec-puppet-facts',                                             require: false
  gem 'rspec-puppet-utils',                                             require: false
  gem 'rubocop-rspec', '~> 1.6',                                        require: false if RUBY_VERSION >= '2.3.0'
end

group :development do
  gem 'guard-rake',                                                     require: false
  gem 'travis',                                                         require: false
  gem 'travis-lint',                                                    require: false
end

group :system_tests do
  gem 'beaker-puppet_install_helper',                                   require: false
  gem 'beaker-rspec',                                                   require: false
  gem 'serverspec',                                                     require: false
end

gem 'facter', '~> 2.4', require: false, groups: [:test]
gem 'puppet', '~> 4.0', require: false, groups: [:test]
