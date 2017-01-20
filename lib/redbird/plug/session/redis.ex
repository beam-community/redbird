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

  def get(_conn, redis_key, _init_options) do
    case get(redis_key) do
      :undefined -> {nil, %{}}
      value -> {redis_key, value |> :erlang.binary_to_term}
    end
  end

  def put(conn, nil, data, init_options) do
    put(conn, generate_random_key(), data, init_options)
  end
  def put(_conn, redis_key, data, init_options) do
    setex(%{key: redis_key, value: data, seconds: session_expiration(init_options)})
    redis_key
  end

  def delete(_conn, redis_key, _kinit_options) do
    del(redis_key)
    :ok
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
