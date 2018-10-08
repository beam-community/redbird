defmodule Redbird do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(Redbird.Redis, [Redbird.Redis.pid()])
    ]

    opts = [strategy: :one_for_one, name: Redbird.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
