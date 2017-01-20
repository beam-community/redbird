defmodule RedbirdTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias Plug.Session.REDIS

  @default_opts [
    store: :redis,
    key: "_session_key",
  ]
  @secret String.duplicate("thoughtbot", 8)

  defp sign_plug(options) do
    options =
      options ++ @default_opts
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

  describe "get" do
    test "when there is value stored it is retrieved" do
      conn = conn(:get, "/")
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
      conn = conn(:get, "/")
           |> sign_conn
           |> put_session(:foo, "bar")
           |> send_resp(200, "")
      assert conn |> get_session(:foo) == "bar"
    end

    test "it allows configuring session expiration" do
      conn = conn(:get, "/")
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
end
