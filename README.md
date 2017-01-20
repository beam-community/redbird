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
      {:redbird, "~> 0.1.0"},
    ]
  end
```

### Configure ExRedis

For a all configuration options, please see the [ExRedis GitHub page]

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

![thoughtbot](https://thoughtbot.com/logo.png)

Redbird is maintained and funded by thoughtbot, inc.
The names and logos for thoughtbot are trademarks of thoughtbot, inc.

We love open source software, Elixir, and Phoenix. See [our other Elixir
projects][elixir-phoenix], or [hire our Elixir Phoenix development team][hire]
to design, develop, and grow your product.

  [elixir-phoenix]: https://thoughtbot.com/services/elixir-phoenix?utm_source=github
  [hire]: https://thoughtbot.com?utm_source=github
