defmodule Redbird.Redis do
  def get(key) do
    pid()
    |> Redix.command!(["GET", key])
    |> case do
      nil -> :undefined
      response -> response
    end
  end

  def setex(%{key: key, value: value, seconds: seconds}) do
    pid()
    |> Redix.command(["SETEX", key, seconds, value])
    |> case do
      {:ok, "OK"} -> :ok
      {:error, error} -> error
    end
  end

  def del(keys) when is_list(keys) do
    pid()
    |> Redix.noreply_command(["DEL" | keys])
  end

  def del(key) when is_binary(key) do
    del([key])
  end

  def keys(pattern) do
    pid()
    |> Redix.command!(["KEYS", pattern])
  end

  def pid do
    :redbird_phoenix_session
  end
end
