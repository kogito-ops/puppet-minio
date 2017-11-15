require 'puppetlabs_spec_helper/rake_tasks.rb'
require 'puppet_blacksmith/rake_tasks.rb'
require 'puppet-lint/tasks/puppet-lint.rb'
require 'metadata-json-lint/rake_task.rb'

if RUBY_VERSION >= '1.9'
  require 'rubocop/rake_task.rb'
  RuboCop::RakeTask.new
end

exclude_paths = %w[
  pkg/**/*
  vendor/**/*
  .vendor/**/*
  spec/**/*
]

PuppetLint.configuration.log_format = '%{path}:%{line}:%{check}:%{KIND}:%{message}'
PuppetLint.configuration.fail_on_warnings = true
PuppetLint.configuration.relative = true
PuppetLint.configuration.send('relative')
PuppetLint.configuration.send('disable_140chars')
PuppetLint.configuration.send('disable_class_inherits_from_params_class')
PuppetLint.configuration.send('disable_documentation')
PuppetLint.configuration.send('disable_single_quote_string_with_variables')
PuppetLint.configuration.ignore_paths = exclude_paths
PuppetSyntax.exclude_paths = exclude_paths

desc 'Validate manifests, templates, and ruby files'
task :validate do
  Dir['manifests/**/*.pp'].each do |manifest|
    sh "puppet parser validate --noop #{manifest}"
  end
  Dir['spec/**/*.rb', 'lib/**/*.rb'].each do |ruby_file|
    sh "ruby -c #{ruby_file}" unless ruby_file =~ %r{spec/fixtures}
  end
  Dir['templates/**/*.erb'].each do |template|
    sh "erb -P -x -T '-' #{template} | ruby -c"
  end
end

desc 'Run metadata_lint, lint, rubocop, validate, and spec tests.'
task :test do
  [:metadata_lint, :lint, :validate, :rubocop, :spec].each do |test|
    Rake::Task[test].invoke
  end
end
