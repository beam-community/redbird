defmodule RedbirdTest do
  use Redbird.ConnCase
  import Mock
  alias Plug.Session.REDIS

  setup_all do
    Application.stop(:redbird)
    :ok = Application.start(:redbird)
  end

  setup do
    on_exit(fn ->
      Redbird.Redis.keys(Redbird.Key.namespace() <> "*")
      |> Redbird.Redis.del()
    end)
  end

  describe "get" do
    test "when there is value stored it is retrieved" do
      secret = generate_secret()

      conn =
        :get
        |> conn("/")
        |> sign_conn_with(secret)
        |> put_session(:foo, "bar")
        |> send_resp(200, "")

      conn =
        :get
        |> conn("/")
        |> recycle_cookies(conn)
        |> sign_conn_with(secret)
        |> send_resp(200, "")

      assert get_session(conn, :foo) == "bar"
    end

    test "when there is no session with the key, it returns {:nil, %{}}" do
      key = "redis_session"
      conn = :get |> conn("/") |> sign_conn()
      options = []

      assert {nil, %{}} = REDIS.get(conn, key, options)
    end
  end

  describe "put" do
    test "it sets the session properly" do
      conn =
        :get
        |> conn("/")
        |> sign_conn()
        |> put_session(:foo, "bar")
        |> send_resp(200, "")

      assert get_session(conn, :foo) == "bar"
    end

    test "it allows configuring session expiration" do
      conn =
        :get
        |> conn("/")
        |> sign_conn(expiration_in_seconds: 1)
        |> put_session(:foo, "bar")
        |> send_resp(200, "")

      :timer.sleep(1000)

      conn =
        :get
        |> conn("/")
        |> recycle_cookies(conn)
        |> sign_conn()
        |> send_resp(200, "")

      assert conn |> get_session(:foo) |> is_nil
    end

    test "it throws an exception after multiple attempts to store and fail" do
      with_mock Redbird.Redis, setex: fn _ -> "FAIL" end do
        assert_raise Redbird.RedisError,
                     ~r/Redbird was unable to store the session in redis. Redis Error: FAIL/,
                     fn ->
                       :get
                       |> conn("/")
                       |> sign_conn()
                       |> put_session(:foo, "bar")
                       |> send_resp(200, "")
                     end
      end
    end
  end

  describe "delete" do
    test "delete session" do
      key = "redis_session"
      conn = :get |> conn("/") |> sign_conn()
      options = []
      REDIS.put(conn, key, %{foo: :bar}, options)
      REDIS.delete(conn, key, options)

      assert {nil, %{}} = REDIS.get(conn, key, options)
    end
  end

  test "redbird_session is preprended to key names by default" do
    conn = :get |> conn("/") |> sign_conn()
    options = []
    key = REDIS.put(conn, nil, %{foo: :bar}, options)

    assert key =~ ~r(\Aredbird_session_)
  end

  test "user can set their own key namespace" do
    Application.put_env(:redbird, :key_namespace, "test_")

    ensure_no_keys_with_prefix("test_")

    conn = :get |> conn("/") |> sign_conn()
    options = []
    key = REDIS.put(conn, nil, %{foo: :bar}, options)

    assert key =~ ~r(\Atest_)
    Application.delete_env(:redbird, :key_namespace)
  end

  defp ensure_no_keys_with_prefix(prefix) do
    (prefix <> "*")
    |> Redbird.Redis.keys()
    |> Redbird.Redis.del()
  end
end
