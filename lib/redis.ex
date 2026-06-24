defmodule Redbird.Redis do
  @moduledoc """
  Redis helper functions for Redbird.
  """

  require Logger

  @doc """
  Configured behavior when a Redis command fails with a connection error.

    * `:raise` (default) — preserve historical behavior: let the error
      propagate so the request crashes.
    * `:fail_open` — treat Redis as unavailable: session reads return no
      session and writes are skipped, so a Redis outage degrades to
      "no session" instead of crashing every request that touches a session.
  """
  def on_redis_error do
    Application.get_env(:redbird, :on_redis_error, :raise)
  end

  def child_spec(args) do
    %{
      id: Redbird.Redis,
      start: {Redbird.Redis, :start_link, [args]}
    }
  end

  def start_link(opts) do
    Redix.start_link(opts)
  end

  def get(key) do
    case Redix.command(pid(), ["GET", key]) do
      {:ok, nil} -> :undefined
      {:ok, response} -> response
      {:error, error} -> get_error(key, error)
    end
  end

  defp get_error(key, error) do
    case on_redis_error() do
      :fail_open ->
        Logger.warning(
          "Redbird: failing open on session read for #{inspect(key)}; Redis error: #{inspect(error)}"
        )

        :undefined

      :raise ->
        raise error
    end
  end

  def setex(%{key: key, value: value, seconds: seconds}) do
    result = Redix.command(pid(), ["SETEX", key, seconds, value])

    case result do
      {:ok, "OK"} -> :ok
      {:error, error} -> error
    end
  end

  def del(keys) when is_list(keys) do
    Redix.noreply_command(pid(), ["DEL" | keys])
  end

  def del(key) when is_binary(key) do
    del([key])
  end

  def keys(pattern) do
    Redix.command!(pid(), ["KEYS", pattern])
  end

  def pid do
    :redbird_phoenix_session
  end
end
