[![CircleCI](https://circleci.com/gh/thoughtbot/redbird.svg?style=svg&circle-token=ffeb06ba85ab9e15f98730027745be851d647b61&branch=master)](https://circleci.com/gh/thoughtbot/redbird)

# Redbird

**Redbird is part of the [thoughtbot Elixir family][elixir-phoenix] of projects.**

Redbird is a Redis session adapter for Plug.Session.
It works great for Phoenix!

## Installation

### Add Redbird to your application and dependency list.

```elixir
  def applications do
    [
      :redbird,
    ]
  end

  def deps do
    [
      {:redbird, "~> 0.4.0"},
    ]
  end
```

### Configure ExRedis

For all configuration options, please see the [ExRedis GitHub page]

```elixir
config :exredis, url: System.get_env("REDIS_URL")
```

  [ExRedis GitHub page]: https://github.com/artemeff/exredis

### Configure Plug

```elixir
plug Plug.Session,
  store: :redis,
  key: "_app_key",
  expiration_in_seconds: 3000 # Optional - default is 30 days
```

### Configure Redbird

All redbird created keys are automatically namespaced with `redbird_session` by
default. If you'd like to set your own custom, per app, configuration you can
set that in the config.

```elixir
config :redbird, key_namespace: "my_app_"
```

### Mix Tasks

This will give you access to the mix task `mix redbird.delete_all_sessions`, for
clearing all Redbird created user sessions from Redis. If you have not set up a
per app `key_namespace` in the config this will clear ALL Redbird sessions on
your server. Otherwise it will only clear the sessions created by the specific
app you're running it in.

## Contributing

See the [CONTRIBUTING] document.
Thank you, [contributors]!

  [CONTRIBUTING]: CONTRIBUTING.md
  [contributors]: https://github.com/thoughtbot/redbird/graphs/contributors

## License

Redbird is Copyright (c) 2017 thoughtbot, inc.
It is free software, and may be redistributed
under the terms specified in the [LICENSE] file.

  [LICENSE]: /LICENSE

## About

![thoughtbot](http://presskit.thoughtbot.com/images/thoughtbot-logo-for-readmes.svg)

Redbird is maintained and funded by thoughtbot, inc.
The names and logos for thoughtbot are trademarks of thoughtbot, inc.

We love open source software, Elixir, and Phoenix. See [our other Elixir
projects][elixir-phoenix], or [hire our Elixir Phoenix development team][hire]
to design, develop, and grow your product.

  [elixir-phoenix]: https://thoughtbot.com/services/elixir-phoenix?utm_source=github
  [hire]: https://thoughtbot.com?utm_source=github
