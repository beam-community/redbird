defmodule Redbird.ResilienceTest do
  @moduledoc """
  Fail-open behaviour: when Redis is unreachable, redbird should degrade to
  "no session" rather than raising and crashing every session-touching request.

  Gated by `config :redbird, on_redis_error: :fail_open | :raise` (default
  `:raise`, preserving historical behaviour).
  """
  use Redbird.ConnCase

  import Mock

  alias Plug.Session.REDIS

  @conn_error %Redix.ConnectionError{reason: :closed}

  describe "Redbird.Redis.get/1 (read path)" do
    test "fails open (returns :undefined) on a connection error when :fail_open" do
      set_error_mode(:fail_open)

      with_mock Redix, command: fn _conn, ["GET", _key] -> {:error, @conn_error} end do
        assert Redbird.Redis.get("redbird_session_abc") == :undefined
      end
    end

    test "re-raises on a connection error when :raise (default)" do
      with_mock Redix, command: fn _conn, ["GET", _key] -> {:error, @conn_error} end do
        assert_raise Redix.ConnectionError, fn ->
          Redbird.Redis.get("redbird_session_abc")
        end
      end
    end
  end

  describe "session write (put) path" do
    test "fails open (returns the key, no raise) when writes keep failing and :fail_open" do
      set_error_mode(:fail_open)

      with_mock Redbird.Redis, [:passthrough], setex: fn _ -> @conn_error end do
        key = REDIS.put(signed_conn(), nil, %{foo: "bar"}, [])
        assert is_binary(key)
      end
    end
  end

  describe "Redbird.RedisError.raise/1" do
    test "raises Redbird.RedisError on a Redix.ConnectionError, not a String.Chars crash" do
      assert_raise Redbird.RedisError, fn ->
        Redbird.RedisError.raise(error: @conn_error, key: "redbird_session_abc")
      end
    end
  end

  defp set_error_mode(mode) do
    Application.put_env(:redbird, :on_redis_error, mode)
    on_exit(fn -> Application.delete_env(:redbird, :on_redis_error) end)
  end
end
