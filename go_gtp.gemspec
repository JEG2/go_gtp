Gem::Specification.new do |s|
  s.name        = "go_gtp"
  s.version     = "0.0.5.alpha"
  s.authors     = ["James Edward Gray II", "Ryan Bates"]
  s.email       = ["james@graysoftinc.com"]
  s.homepage    = "http://github.com/JEG2/go_gtp"
  s.summary     = "A wrapper for GNU Go's Go Text Protocol (GTP)."
  s.description = <<-END_DESCRIPTION.gsub(/\s+/, " ").strip
  This library runs GNU Go in a separate process and allows you to communicate
  with it using the Go Text Protocol (GTP).  This makes it easy to manage full
  games of Go, work with SGF files, analyze Go positions, and more.
  END_DESCRIPTION

  s.files        = Dir["{lib,spec}/**/*", "[A-Z]*"]
  s.require_path = "lib"

  s.add_development_dependency 'rspec'

  s.rubyforge_project = s.name
  s.required_ruby_version = "~> 1.9.2"
  s.required_rubygems_version = ">= 1.3.6"
end
