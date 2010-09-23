require "rake"
require "spec/rake/spectask"
require "rake/gempackagetask"

task :default => :spec

Spec::Rake::SpecTask.new do |rspec|
  rspec.warning = true
end

load(File.join(File.dirname(__FILE__), "go_gtp.gemspec"))
Rake::GemPackageTask.new(SPEC) do |package|
  # do nothing:  I just need a gem but this block is required
end
