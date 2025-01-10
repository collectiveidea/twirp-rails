# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in twirp-rails.gemspec
gemspec

gem "rake"

gem "rails", "~> #{ENV["RAILS_VERSION"] || "8.0"}"

gem "debug"
gem "rspec-rails"
gem "standard", ">= 1.35.1"
gem "standard-performance"
gem "standard-rails"

# These standard library gems need to be here for with certain Rails 7/Ruby 3.4 combinations. Delete eventually.
gem "mutex_m"
gem "bigdecimal"
gem "drb"
