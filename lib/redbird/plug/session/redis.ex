defmodule Plug.Session.REDIS do
  import Redbird.Redis
  alias Redbird.{Key, Value}

  @moduledoc """
  Stores the session in a redis store.
  """

  @behaviour Plug.Session.Store

  @max_session_time 86_164 * 30

  def init(opts) do
    opts
  end

  def get(conn, prospective_key, init_options) do
    max_age = session_expiration(init_options)

    with true <- Key.accessible?(prospective_key, conn, max_age: max_age),
         value when is_binary(value) <- get(prospective_key) do
      {prospective_key, Value.deserialize(value)}
    else
      _ -> {nil, %{}}
    end
  end

  def put(conn, nil, data, init_options) do
    key =
      Key.generate()
      |> Key.sign_key(conn)

    put(conn, key, data, init_options)
  end

  def put(conn, key, data, init_options) do
    max_age = session_expiration(init_options)

    if Key.accessible?(key, conn, max_age: max_age) do
      key
      |> set_key_with_retries(Value.serialize(data), max_age, 1)
    else
      put(conn, nil, data, init_options)
    end
  end

  def delete(conn, redis_key, init_options) do
    max_age = session_expiration(init_options)

    if Key.accessible?(redis_key, conn, max_age: max_age), do: del(redis_key)

    :ok
  end

  defp set_key_with_retries(key, value, seconds, counter) do
    case setex(%{key: key, value: value, seconds: seconds}) do
      :ok ->
        key

      response ->
        if counter > 5 do
          Redbird.RedisError.raise(error: response, key: key)
        else
          set_key_with_retries(key, value, seconds, counter + 1)
        end
    end
  end

  defp session_expiration(opts) do
    case opts[:expiration_in_seconds] do
      seconds when is_integer(seconds) -> seconds
      _ -> @max_session_time
    end
  end
end

defmodule Redbird.RedisError do
  defexception [:message]
  @base_message "Redbird was unable to store the session in redis."

  def raise(error: error, key: key) do
    message = "#{@base_message} Redis Error: #{error} key: #{key}"
    raise __MODULE__, message
  end

  def exception(message) do
    %__MODULE__{message: message}
  end
end
