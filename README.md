[![Gem Version](https://img.shields.io/gem/v/twirp-on-rails.svg)](https://rubygems.org/gems/twirp-on-rails)
[![CI](https://github.com/collectiveidea/twirp-rails/actions/workflows/ci.yml/badge.svg)](https://github.com/collectiveidea/twirp-rails/actions/workflows/ci.yml)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/testdouble/standard)

# Twirp on Rails (Twirp::Rails)

## Motivation

Serving [Twirp](https://twitchtv.github.io/twirp/) RPC Services should be as easy and familiar as Rails controllers. We add a few helpful abstractions, but don't hide [Twirp](https://twitchtv.github.io/twirp/), [Protobufs](https://protobuf.dev), or make it seem too magical.

Out of the box, the [`twirp` gem](http://github.com/github/twirp-ruby) lets you add [Services](https://github.com/github/twirp-ruby/wiki/Service-Handlers), but it feels clunky coming from Rails REST-ful APIs. We make it simple to build full-featured APIs. Hook in authorization, use `before_action` and more.

Extracted from a real, production application with many thousands of users.

## Installation

Install the gem using `gem install twirp-on-rails` or simply add it to your `Gemfile`:

```
gem "twirp-on-rails"
```

## Usage

Add to your `routes.rb`:

```ruby
mount Twirp::Rails::Engine, at: "/twirp"
```

### Generate your `_pb.rb` and `_twirp.rb` files

Generate files [how Twirp-Ruby recommends](https://github.com/arthurnn/twirp-ruby/wiki/Code-Generation). 

Example: 

```bash
protoc --ruby_out=./lib --twirp_ruby_out=./lib  haberdasher.proto
```

We (currently) don't run `protoc` for you and have no opinions where you put the generated files. 

Ok, one small opinion: we default to looking in `lib/`, but you can change that.

### Configuration

Twirp::Rails will automatically load any `*_twirp.rb` files in your app's `lib/` directory (and subdirectories). To modify the location, add this to an initializer: 

```ruby 
Rails.application.config.load_paths = ["lib", "app/twirp"]
```

## Features

### Easy Routing

Add one line to your `config/routes.rb` and routes are built automatically from your Twirp Services:

```ruby
mount Twirp::Rails::Engine, at: "/twirp"
```

`/twirp/twirp.example.haberdasher.HaberdasherService/MakeHat`

These are routed to Handlers in `app/handlers/` based on expected naming conventions.

For example if you have this service defined: 

```protobuf
package twirp.example.haberdasher;

service HaberdasherService {
   rpc MakeHat(Size) returns (Hat);
 }
```

it will expect to find `app/handlers/haberdasher_service_handler.rb` with a `make_hat` method. 

```ruby
class HaberdasherServiceHandler < Twirp::Rails::Handler
  def make_hat

  end
end
```

Each handler method should return the appropriate Protobuf, or a `Twirp::Error`.

#### Packages and Namespacing

Handlers can live in directories that reflect the service's package. For example, `haberdasher.proto` defines:

```protobuf
package twirp.example.haberdasher;
```

You can use the full path, or because many projects have only one namespace, we also let you skip the namespace for simplicity:

We look for the handler in either location:

`app/handlers/twirp/example/haberdasher/haberdasher_service_handler.rb` defines `Twirp::Example::Haberdasher::HaberdasherServiceHandler`

or

`app/handlers/haberdasher_service_handler.rb` defines `HaberdasherServiceHandler`


TODO: Give more examples of handlers

### Familiar Callbacks

Use `before_action`, `around_action`, and other callbacks you're used to, as we build on [AbstractController::Callbacks](https://api.rubyonrails.org/classes/AbstractController/Callbacks.html).

### rescue_from

Use `rescue_from` just like you would in a controller: 

```ruby
class HaberdasherServiceHandler < Twirp::Rails::Handler
  rescue_from "ArgumentError" do |error|
    Twirp::Error.invalid_argument(error.message)
  end

  rescue_from "Pundit::NotAuthorizedError", :not_authorized

  ...
end
```

### DRY Service Hooks

Apply [Service Hooks](https://github.com/twitchtv/twirp-ruby/wiki/Service-Hooks) one time across multiple services.

For example, we can add hooks in an initializer: 

```ruby
# Make IP address accessible to the handlers
Rails.application.config.twirp.service_hooks[:before] = lambda do |rack_env, env|
  env[:ip] = rack_env["REMOTE_ADDR"]
end

# Send exceptions to Honeybadger
Rails.application.config.twirp.service_hooks[:exception_raised] = ->(exception, _env) { Honeybadger.notify(exception) }
```

### Middleware

As an Engine, we avoid all the standard Rails middleware. That's nice for simplicity, but sometimes you want to add your own middleware. You can do that by specifying it in an initializer:

```ruby
Rails.application.config.twirp.middleware = [Rack::Deflater]
```

### Logging

Our built-in logging outputs the result of each request. 

You could replace our logger if you want different output: 

```ruby
Rails.application.config.twirp.logger = Rack::CommonLogger
```

Additionally, you can log the Twirp response object to help with debugging: 

```ruby
# Defaults to true if your log_level is :debug
Rails.application.config.twirp.verbose_logging = true
```

## Bonus Features

Outside the [Twirp spec](https://twitchtv.github.io/twirp/docs/spec_v7.html), we have some (optional) extra magic. They might be useful to you, but you can easily ignore them too.

### Basic Caching with ETags/If-None-Match Headers

Like Rails GET actions, Twirp::Rails handlers add [`ETag` headers](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/ETag) based on the response's content.

If you have RPCs that can be cached, you can have your Twirp clients send an [`If-None-Match` Header](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/If-None-Match). Twirp::Rails will return a `304 Not Modified` HTTP status and not re-send the body if the ETag matches.

Enable by adding this to an initializer:

```ruby
Rails.application.config.twirp.middleware = [
  Twirp::Rails::Rack::ConditionalPost,
  Rack::ETag
]
```

Note: The Handler will still be run, but you won't need to send back the response. Make sure your RPC is idempotent! Future versions hope to make it easier to short-circuit expensive parts of the handler. 

## TODO

* More docs!
* More tests!
* installer generator to add `ApplicationHandler`
    * Maybe a generator for individual handlers that adds that if needed?
* Auto reload.
* Make service hooks more configurable? Apply to one service instead of all?
* Loosen Rails version requirement? Probably works, but haven't tested. 

## Prior Art

We evaluated all these projects and found them to be bad fits for us, for one reason or another. We're grateful to all for their work, and hope they continue and flourish. Some notes from our initial evaluation:

[nikushi/twirp-rails](https://github.com/nikushi/twirp-rails)

* Nice routing abstraction
* Minimal Handler abstraction
* Untouched for 4 years

[cheddar-me/rails-twirp](https://github.com/cheddar-me/rails-twirp)

* Too much setup.
* Nice controllers, but expects you to use their [pbbuilder](https://github.com/cheddar-me/pbbuilder) which I find unnecessary.

[severgroup-tt/twirp_rails-1](https://github.com/severgroup-tt/twirp_rails-1)

* Some nice things
* No Handler abstractions
* Archived and not touched for 3 years

[dudo/rails_respond_to_pb](https://github.com/dudo/rails_respond_to_pb)

* Allows routing to existing controllers
* I dislike the `respond_to` stuff. That shouldn't be something you think about. We have a better way to do that in other recent apps anyway.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/danielmorrison/twirp-rails.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
