# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "vector-generate"
  s.version     = "0.0.0"
  s.platform    = Gem::Platform::RUBY
  s.licenses    = ['Mozilla Public License v2.0 (https://www.mozilla.org/MPL/2.0/)']
  s.authors     = ["Ben Johnson"]
  s.email       = ["bjohnson@binarylogic.com"]
  s.homepage    = "https://github.com/timberio/vector-generate"
  s.summary     = "An internal libary for the Vector.dev project, used to load Vector's metadata and render ERB templates."
  s.description = "An internal libary for the Vector.dev project, used to load Vector's metadata and render ERB templates."

  s.required_ruby_version     = ">= 2.7.0"

  s.add_dependency("activesupport", "~> 6.0")
  s.add_dependency("differ", "~> 0.1")
  s.add_dependency("front_matter_parser", "~> 0.2")
  s.add_dependency("json_schemer", "~> 0.2.8")
  s.add_dependency("paint", "~> 2.1")
  s.add_dependency("toml-rb", "~> 2.0")
  s.add_dependency("unindent", "~> 1.0")
  s.add_dependency("word_wrap", "~> 1.0")

  all_files = `git ls-files`.split("\n")
  test_files = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.files         = all_files - test_files
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]
end
