require_relative 'lib/pylon/version'

Gem::Specification.new do |spec|
  spec.name          = "pylon-api"
  spec.version       = Pylon::VERSION
  spec.authors       = ["Ben Odom"]
  spec.email         = ["support@aptible.com"]

  spec.summary       = "Ruby client for the Pylon API"
  spec.description   = "A Ruby client library for interacting with the Pylon REST API"
  spec.homepage      = "https://github.com/aptible/pylon-ruby"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://docs.usepylon.com/pylon-docs/developer/api/api-reference"

  spec.files = Dir.glob("lib/**/*") + %w[README.md LICENSE.txt]
  
  spec.add_dependency "faraday", "~> 2.0"
  spec.add_dependency "faraday-multipart", "~> 1.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.0"
  spec.add_development_dependency "simplecov", "~> 0.22.0"
end
