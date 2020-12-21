defmodule Redbird do
  use Application

  def start(_type, _args) do
    redis_options = Redbird.Config.redis_options(name: Redbird.Redis.pid())

    children = [
      {Redix, redis_options}
    ]

    opts = [strategy: :one_for_one, name: Redbird.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
