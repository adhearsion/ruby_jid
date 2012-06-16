# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ruby_jid/version"

Gem::Specification.new do |s|
  s.name        = "ruby_jid"
  s.version     = RubyJID::VERSION
  s.authors     = ["Ben Langfeld", "David Graham", "Jeff Smick"]
  s.email       = ["ben@langfeld.me"]
  s.homepage    = ""
  s.summary     = %q{A Ruby representation of an XMPP JID}
  s.description = %q{Provides parsing, validation & accessors}

  s.rubyforge_project = "ruby_jid"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'bundler', ["~> 1.0"]
  s.add_development_dependency 'rspec', ["~> 2.8"]
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'simplecov-rcov'
  s.add_development_dependency 'yard', ["~> 0.6"]
  s.add_development_dependency 'rake'
  s.add_development_dependency 'guard-rspec'
end
