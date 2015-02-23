# encoding: utf-8

require 'rubygems'
require 'rake'

require 'jeweler'
require './lib/tdp/version.rb'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://guides.rubygems.org/specification-reference/ for more options
  gem.name = "tdp"
  gem.version = TDP::VERSION
  gem.homepage = "http://github.com/cthielecke/tdp"
  gem.license = "MIT"
  gem.summary = "Templated data provisioning or the poor man's Q-Up"
  gem.description = %Q{This tool is a small DSL designed to glue together arbitrary templates and configurations to provide data specifications in a versatile and easy way.
As there are no limitations on what to specify with a template, neither will the usage of this tool be limited to specific domains of use.
It was initially intended to generate a host of XML test data specifications in a reproducible way.
For automation purposes the use of Rake or some similar tool is mandatory.}
  gem.email = "carsten.thielecke@ieee.org"
  gem.authors = ["Carsten Thielecke"]
  gem.platform = Gem::Platform::RUBY
  gem.required_ruby_version = '>=1.9'
  gem.files = FileList[
	'[A-Z]*',
    'bin/*',
	'lib/**/*',
	'test/**/*',
  ].to_a
  gem.executables = [ 'tdp' ]
  gem.test_files = Dir["test/test*.rb"]
  gem.has_rdoc = true
  
  # Include your dependencies below. Runtime dependencies are required when using your gem,
  # and development dependencies are only needed for development (ie running rake tasks, tests, etc)
  gem.add_development_dependency "jeweler", "~> 2.0.1"
  gem.add_development_dependency "simplecov", ">= 0"
  
  gem.add_runtime_dependency "erubis", ">= 2.7"
  
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

desc "Code coverage detail"
task :simplecov do
  ENV['COVERAGE'] = "true"
  Rake::Task['test'].execute
end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : TDP::VERSION

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "tdp #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
