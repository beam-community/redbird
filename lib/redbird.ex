defmodule Redbird do
  @moduledoc """
  Redbird application.
  """

  use Application

  def start(_type, _args) do
    redis_options = Application.get_env(:redbird, :redis_options, [])

    children = [
      {Redbird.Redis, [{:name, Redbird.Redis.pid()} | redis_options]}
    ]

    opts = [strategy: :one_for_one, name: Redbird.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
