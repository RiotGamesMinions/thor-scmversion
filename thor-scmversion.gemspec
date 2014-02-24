# -*- encoding: utf-8 -*-
require File.expand_path('../lib/thor-scmversion/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Michael Ivey", "Kyle Allan", "Josiah Kiehl"]
  gem.email         = ["ivey@gweezlebur.com", "kallan@riotgames.com", "josiah@skirmisher.net"]
  gem.description   = %q{Thor tasks to manage a VERSION file based on SCM tags}
  gem.summary       = %q{A small set of Thor tasks you can include in your build scripts to manage a VERSION file based on SCM tags. This allows you to keep VERSION out of cource control, allowing your continuous integration system to version each build.}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "thor-scmversion"
  gem.require_paths = ["lib"]
  gem.version       = ThorSCMVersion::VERSION

  gem.add_dependency 'thor'
  gem.add_dependency 'mixlib-shellout'

  gem.add_development_dependency 'webmock'
  gem.add_development_dependency 'geminabox'
  gem.add_development_dependency 'spork'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'vcr'
  gem.add_development_dependency 'aruba'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'debugger'
end
