# frozen_string_literal: true

require_relative "lib/twirp/rails/version"

Gem::Specification.new do |spec|
  spec.name = "twirp-on-rails"
  spec.version = Twirp::Rails::VERSION
  spec.authors = ["Daniel Morrison", "Darron Schall"]
  spec.email = ["info@collectiveidea.com"]

  spec.summary = "Use Twirp RPC with Rails"
  spec.description = "A simple way to serve Twirp RPC services in a Rails app. Minimial configuration and familiar Rails conventions."
  spec.homepage = "https://github.com/collectiveidea/twirp-rails"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/collectiveidea/twirp-rails"
  spec.metadata["changelog_uri"] = "https://github.com/collectiveidea/twirp-rails/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 7.0.0"
  spec.add_dependency "twirp", ">= 1.8.0"
end
