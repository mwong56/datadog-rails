$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "datadog_rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "datadog_rails"
  s.version     = DatadogRails::VERSION
  s.authors     = ["Henrique Menezes"]
  s.email       = ["henrique@mesainc.com.br"]
  s.homepage    = "https://github.com/mesainc/datadog-rails"
  s.summary     = "Send Rails application metrics to DogStatsD."
  s.description = "This gem sends Rails application metrics to DogStatsD"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  
  s.add_dependency "rails", "~> 5.1.4"
  s.add_dependency "dogstatsd-ruby", "~> 3.1.0"
end
