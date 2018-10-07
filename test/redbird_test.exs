defmodule RedbirdTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias Plug.Session.REDIS
  import Mock

  @default_opts [
    store: :redis,
    key: "_session_key"
  ]
  @secret String.duplicate("thoughtbot", 8)

  defp sign_plug(options) do
    options =
      (options ++ @default_opts)
      |> Keyword.put(:encrypt, false)

    Plug.Session.init(options)
  end

  defp sign_conn(conn, options \\ []) do
    put_in(conn.secret_key_base, @secret)
    |> Plug.Session.call(sign_plug(options))
    |> fetch_session
  end

  setup_all do
    Application.stop(:redbird)
    :ok = Application.start(:redbird)
  end

  setup do
    on_exit(fn ->
      Redbird.Redis.keys(Plug.Session.REDIS.namespace() <> "*")
      |> Redbird.Redis.del()
    end)
  end

  describe "get" do
    test "when there is value stored it is retrieved" do
      conn =
        conn(:get, "/")
        |> sign_conn
        |> put_session(:foo, "bar")
        |> send_resp(200, "")

      conn =
        conn(:get, "/")
        |> recycle_cookies(conn)
        |> sign_conn
        |> send_resp(200, "")

      assert conn |> get_session(:foo) == "bar"
    end

    test "when there is no session with the key, it returns {:nil, %{}}" do
      key = "redis_session"
      conn = %{}
      options = []

      assert {nil, %{}} = REDIS.get(conn, key, options)
    end
  end

  describe "put" do
    test "it sets the session properly" do
      conn =
        conn(:get, "/")
        |> sign_conn
        |> put_session(:foo, "bar")
        |> send_resp(200, "")

      assert conn |> get_session(:foo) == "bar"
    end

    test "it allows configuring session expiration" do
      conn =
        conn(:get, "/")
        |> sign_conn(expiration_in_seconds: 1)
        |> put_session(:foo, "bar")
        |> send_resp(200, "")

      :timer.sleep(1000)

      conn =
        conn(:get, "/")
        |> recycle_cookies(conn)
        |> sign_conn
        |> send_resp(200, "")

      assert conn |> get_session(:foo) |> is_nil
    end

    test "it throws an exception after multiple attempts to store and fail" do
      with_mock Redbird.Redis, setex: fn _ -> "FAIL" end do
        assert_raise Redbird.RedisError,
                     ~r/Redbird was unable to store the session in redis. Redis Error: FAIL/,
                     fn ->
                       conn(:get, "/")
                       |> sign_conn
                       |> put_session(:foo, "bar")
                       |> send_resp(200, "")
                     end
      end
    end
  end

  describe "delete" do
    test "delete session" do
      key = "redis_session"
      conn = %{}
      options = []
      REDIS.put(conn, key, %{foo: :bar}, options)
      REDIS.delete(conn, key, options)

      assert {nil, %{}} = REDIS.get(conn, key, options)
    end
  end

  test "redbird_session is appended to key names by default" do
    conn = %{}
    options = []
    key = REDIS.put(conn, nil, %{foo: :bar}, options)

    assert key =~ "redbird_session_"
  end

  test "user can set their own key namespace" do
    Application.put_env(:redbird, :key_namespace, "test_")

    Redbird.Redis.keys("test_*")
    |> Redbird.Redis.del()

    conn = %{}
    options = []
    key = REDIS.put(conn, nil, %{foo: :bar}, options)

    assert key =~ "test_"
    Application.delete_env(:redbird, :key_namespace)
  end
end
