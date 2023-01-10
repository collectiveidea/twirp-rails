# Twirp::Rails

## Motivation

Make serving a Twirp RPC Services as easy and familiar as Rails controllers. Add a few helpful abstractions, but don't hide Twirp, Protobufs, or make it seem too magical.

Out of the box, the [`twirp` gem](http://github.com/github/twirp-ruby) makes it easy to add Services, but it feels clunky coming from Rails REST-ful APIs. We make it simple to build full-featured APIs. Hook in authorization, `before_action` and more.

Extracted from a real, production application with many thousands of users.

## Features

### Easy Routing

Add one line to your `config/routes.rb` and routes are built automatically from your Twirp Services:

```ruby
mount Twirp::Rails::Engine, at: "/twirp"
```

`/twirp/twirp.example.haberdasher.Haberdasher/MakeHat`

These are routed to Handlers in `app/handlers/` based on expected naming conventions.

### Familiar Callbacks

Use `before_action`, `around_action`, and other callbacks you're used to, as we build on [AbstractController::Callbacks](https://api.rubyonrails.org/classes/AbstractController/Callbacks.html).

### DRY Service Hooks

Apply [Service Hooks](https://github.com/twitchtv/twirp-ruby/wiki/Service-Hooks) one time across multiple services.

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

## TODO

* More docs!
* Tests!
* installer generator to add `ApplicationHandler`
** Maybe a generator for individual handlers that adds that if needed?
* Autoload `lib/*_twirp.rb` files.
** Make this location an easy config change
* Make service hooks more configurable? Apply to one service instead of all?


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Prior Art

We evaluated all these projects and found them to be bad fits for me, for one reason or another. We're grateful to all for their work, and hope they continue and flourish. Some notes from our initial evaluation:

[nikushi/twirp-rails](https://github.com/nikushi/twirp-rails)

* Nice routing abstraction
* Minimal Handler abstraction
* Untouched for 4 years

[cheddar-me/rails-twirp](https://github.com/cheddar-me/rails-twirp)

* Too much setup.
* Nice controllers, but expects you to use their (pbbuilder)[https://github.com/cheddar-me/pbbuilder] which I find unnecessary.

(severgroup-tt/twirp_rails-1)[https://github.com/severgroup-tt/twirp_rails-1]

* Some nice things
* No Handler abstractions
* Archived and not touched for 3 years

(dudo/rails_respond_to_pb)[https://github.com/dudo/rails_respond_to_pb]

* Allows routing to existing controllers
* I dislike the `respond_to` stuff. That shouldn't be something you think about. We have a better way to do that in other recent apps anyway.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/danielmorrison/twirp-rails.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
