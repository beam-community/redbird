# Redbird

Redbird is a Redis session adapter for Plug.Session.

It works great for Phoenix!

## Installation

### Add Redbird to your dependency list.

```elixir
  def deps do
    [
      {:redbird, "~> 0.7.1"},
    ]
  end
```

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

### Configure Redix

Redbird uses [Redix] to communicate with Redis. You can pass configuration
options as `redis_options`:

```elixir
config :redbird,
  redis_options: [
    host: System.get_env("REDIS_HOST"),
    port: System.get_env("REDIS_PORT"),
    password: System.get_env("REDIS_PASSWORD"),
    ssl: true
  ]
```

For a full list of configuration options, please see [Redix's connection
options].

  [Redix]: https://hexdocs.pm/redix/Redix.html
  [Redix's connection options]: https://hexdocs.pm/redix/Redix.html#start_link/1-connection-options

### Mix Tasks

This will give you access to the mix task `mix redbird.delete_all_sessions`, for
clearing all Redbird created user sessions from Redis. If you have not set up a
per app `key_namespace` in the config this will clear ALL Redbird sessions on
your server. Otherwise it will only clear the sessions created by the specific
app you're running it in.

## Contributing

Before opening a pull request, please open an issue first.

```
git clone https://github.com/beam-community/redbird.git
cd redbird
mix deps.get
mix test
```

Once you've made your additions and mix test passes, go ahead and open a PR!

## License

Redbird is Copyright (c) 2025 BEAM Community.
It is free software, and may be redistributed
under the terms specified in the [LICENSE] file.

  [LICENSE]: /LICENSE