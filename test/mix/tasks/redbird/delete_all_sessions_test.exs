defmodule Mix.Tasks.Redbird.DeleteAllSessionsTest do
  use Redbird.ConnCase

  alias Plug.Session.REDIS
  alias Mix.Tasks.Redbird.DeleteAllSessions

  setup do
    on_exit(fn ->
      Mix.Tasks.Redbird.DeleteAllSessions.run([])
    end)
  end

  test "deletes all redbird session keys" do
    conn = :get |> conn("/") |> sign_conn()
    options = []
    key = REDIS.put(conn, nil, %{foo: :bar}, options)

    DeleteAllSessions.run([])

    assert {nil, %{}} = REDIS.get(conn, key, options)
  end

  test "deletes user defined namespaced session keys" do
    Application.put_env(:redbird, :key_namespace, "test_")
    conn = :get |> conn("/") |> sign_conn()
    options = []
    key = REDIS.put(conn, nil, %{foo: :bar}, options)

    DeleteAllSessions.run([])

    assert {nil, %{}} = REDIS.get(conn, key, options)
    Application.delete_env(:redbird, :key_namespace)
  end
end
