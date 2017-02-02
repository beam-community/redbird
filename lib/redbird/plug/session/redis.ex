defmodule Plug.Session.REDIS do
  import Redbird.Redis
  require IEx

  @moduledoc """
  Stores the session in a redis store.
  """

  @behaviour Plug.Session.Store

  @max_session_time  86_164 * 30

  def init(opts) do
    opts
  end

  def get(_conn, namespaced_key, _init_options) do
    case get(namespaced_key) do
      :undefined -> {nil, %{}}
      value -> {namespaced_key, value |> :erlang.binary_to_term}
    end
  end

  def put(conn, nil, data, init_options) do
    put(conn, generate_random_key(), data, init_options)
  end
  def put(_conn, redis_key, data, init_options) do
    key = add_namespace(redis_key)
    setex(%{
      key: key,
      value: data,
      seconds: session_expiration(init_options)
    })
    key
  end

  def delete(_conn, redis_key, _kinit_options) do
    del(redis_key)
    :ok
  end

  defp add_namespace(key) do
    namespace <> key
  end

  def namespace do
    Application.get_env(:redbird, :key_namespace, redbird_namespace)
  end

  def redbird_namespace do
    "redbird_session_"
  end

  defp generate_random_key do
    :crypto.strong_rand_bytes(96) |> Base.encode64
  end

  defp session_expiration(opts) do
    case opts[:expiration_in_seconds] do
      seconds when is_integer(seconds) -> seconds
      _ -> @max_session_time
    end
  end
end
