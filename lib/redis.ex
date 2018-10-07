defmodule Redbird.Redis do
  def start_link(name) do
    {:ok, client} = Exredis.start_link()
    true = Process.register(client, name)
    {:ok, client}
  end

  def get(value) do
    Exredis.Api.get(pid(), value)
  end

  def setex(%{key: key, value: value, seconds: seconds}) do
    Exredis.Api.setex(pid(), key, seconds, value)
  end

  def del(key) do
    Exredis.Api.del(pid(), key)
  end

  def keys(pattern) do
    Exredis.Api.keys(pattern)
  end

  def pid do
    :redbird_phoenix_session
  end
end
