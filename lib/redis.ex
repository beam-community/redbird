defmodule Redbird.Redis do
  @moduledoc """
  Redis helper functions for Redbird.
  """

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
    result = Redix.command!(pid(), ["GET", key])

    case result do
      nil -> :undefined
      response -> response
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
