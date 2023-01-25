[![CI](https://github.com/collectiveidea/twirp-rails/actions/workflows/ci.yml/badge.svg)](https://github.com/collectiveidea/twirp-rails/actions/workflows/ci.yml)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/testdouble/standard)

# Twirp::Rails

## Motivation

Make serving a [Twirp](https://twitchtv.github.io/twirp/) RPC Services as easy and familiar as Rails controllers. Add a few helpful abstractions, but don't hide Twirp, Protobufs, or make it seem too magical.

Out of the box, the [`twirp` gem](http://github.com/github/twirp-ruby) makes it easy to add [Services](https://github.com/github/twirp-ruby/wiki/Service-Handlers), but it feels clunky coming from Rails REST-ful APIs. We make it simple to build full-featured APIs. Hook in authorization, `before_action` and more.

Extracted from a real, production application with many thousands of users.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add twirp-rails

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install twirp-rails

## Usage

Add to your `routes.rb`:

```ruby
mount Twirp::Rails::Engine, at: "/twirp"
```

### Configuration

Twirp::Rails will automatically load any `*_twirp.rb` files in your app's `lib/` directory. To modify the location, add this to an initializer: 

```ruby 
Twirp::Rails.configure do |config|
  config.load_paths = ["lib", "app/twirp"]
end
```

## Features

### Easy Routing

Add one line to your `config/routes.rb` and routes are built automatically from your Twirp Services:

```ruby
mount Twirp::Rails::Engine, at: "/twirp"
```

`/twirp/twirp.example.haberdasher.Haberdasher/MakeHat`

These are routed to Handlers in `app/handlers/` based on expected naming conventions.

For example if you have this service defined: 

```
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

TODO: Give more examples of both

### Familiar Callbacks

Use `before_action`, `around_action`, and other callbacks you're used to, as we build on [AbstractController::Callbacks](https://api.rubyonrails.org/classes/AbstractController/Callbacks.html).

### DRY Service Hooks

Apply [Service Hooks](https://github.com/twitchtv/twirp-ruby/wiki/Service-Hooks) one time across multiple services.

For example, we can add hooks in an initializer: 

```ruby
Twirp::Rails.configure do |config|
  # Make IP address accessible to the handlers
  config.service_hooks[:before] = lambda do |rack_env, env|
    env[:ip] = rack_env["REMOTE_ADDR"]
  end

  # Send exceptions to Honeybadger
  config.service_hooks[:exception_raised] = ->(exception, _env) { Honeybadger.notify(exception) }
end
```

## Bonus Features

Outside the Twirp spec, this is some extra magic. They might be useful to you, but you can easily ignore them too.   

### Basic Caching with ETags/If-None-Match Headers

Like Rails GET actions, Twirp::Rails handlers add [`ETag` headers](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/ETag) based on the response's content. 

If you have RPCs can be cached, you can have your Twirp clients send an [`If-None-Match` Header](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/If-None-Match). Twirp::Rails will return a `304 Not Modified` HTTP status and not re-send the body if the ETag matches. 


## TODO

* More docs!
* More tests!
* installer generator to add `ApplicationHandler`
** Maybe a generator for individual handlers that adds that if needed?
* Make service hooks more configurable? Apply to one service instead of all?
* Loosen Rails version requirement? Probably works, but haven't tested. 

## Prior Art

We evaluated all these projects and found them to be bad fits for us, for one reason or another. We're grateful to all for their work, and hope they continue and flourish. Some notes from our initial evaluation:

[nikushi/twirp-rails](https://github.com/nikushi/twirp-rails)

* Nice routing abstraction
* Minimal Handler abstraction
* Untouched for 4 years
* Special thanks to [@nikushi](https://github.com/nikushi) for allowing us to take over the [`twirp-rails` gem](http://rubygems.org/gems/twirp-rails) name ( v0.1.1 was this code). Thanks for your inspiration!

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
