defmodule Plug.Session.REDIS do
  import Redbird.Redis
  alias Redbird.Crypto
  alias Redbird.Key

  @moduledoc """
  Stores the session in a redis store.
  """

  @behaviour Plug.Session.Store

  @max_session_time 86_164 * 30

  def init(opts) do
    opts
  end

  def get(conn, prospective_key, _init_options) do
    with {:ok, key, _} <- Key.extract_key(prospective_key),
         {:ok, _verified_key} <- Key.verify(key, conn),
         value when is_binary(value) <- get(prospective_key) do
      {prospective_key, Crypto.safe_binary_to_term(value)}
    else
      _ -> {nil, %{}}
    end
  end

  def put(conn, nil, data, init_options) do
    put(conn, Key.generate(), data, init_options)
  end

  def put(conn, key, data, init_options) do
    key
    |> Key.sign_key(conn)
    |> set_key_with_retries(:erlang.term_to_binary(data), session_expiration(init_options), 1)
  end

  def delete(conn, redis_key, _init_options) do
    if Key.deletable?(redis_key, conn), do: del(redis_key)

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
