# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "tdp"
  s.version = "0.0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Carsten Thielecke"]
  s.date = "2014-11-10"
  s.description = "This tool is a small DSL designed to glue together arbitrary templates and configurations to provide data specifications in a versatile and easy way.\nAs there are no limitations on what to specify with a template, neither will the usage of this tool be limited to specific domains of use.\nIt was initially intended to generate a host of XML test data specifications in a reproducible way.\nFor automation purposes the use of Rake or some similar tool is mandatory."
  s.email = "carsten.thielecke@ieee.org"
  s.executables = ["tdp"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "bin/tdp",
    "lib/tdp/application.rb",
    "lib/tdp/default_loader.rb",
    "lib/tdp/engine.rb",
    "lib/tdp/keywords.rb",
    "lib/tdp/launcher.rb",
    "lib/tdp/libraries.rb",
    "lib/tdp/system_functions.rb",
    "lib/tdp/tdp_dsl.rb",
    "lib/tdp/tdp_module.rb",
    "lib/tdp/version.rb",
    "tdp.gemspec",
    "test/helper.rb",
    "test/tdp_file.rb",
    "test/templates/footer.erubis",
    "test/templates/groupheader.erubis",
    "test/test_dsl.rb"
  ]
  s.homepage = "http://github.com/cthielecke/tdp"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9")
  s.rubygems_version = "1.8.29"
  s.summary = "Templated data provisioning or the poor man's Q-Up"
  s.test_files = ["test/test_dsl.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<jeweler>, ["~> 2.0.1"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
    else
      s.add_dependency(%q<jeweler>, ["~> 2.0.1"])
      s.add_dependency(%q<simplecov>, [">= 0"])
    end
  else
    s.add_dependency(%q<jeweler>, ["~> 2.0.1"])
    s.add_dependency(%q<simplecov>, [">= 0"])
  end
end
