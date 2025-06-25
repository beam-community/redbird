defmodule Redbird.ConnCase do
  @moduledoc false
  use ExUnit.CaseTemplate

  using do
    quote do
      import Plug.Test
      import Redbird.ConnCase
    end
  end

  @default_opts [store: :redis, key: "_session_key"]

  def signed_conn do
    :get |> Plug.Test.conn("/") |> sign_conn()
  end

  def sign_conn(conn, options \\ []) do
    sign_conn_with(conn, generate_secret(), options)
  end

  def sign_conn_with(conn, secret, opts \\ []) do
    conn.secret_key_base
    |> put_in(secret)
    |> Plug.Session.call(sign_plug(opts))
    |> Plug.Conn.fetch_session()
  end

  def generate_secret(length \\ 10) do
    length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64()
    |> binary_part(0, length)
  end

  defp sign_plug(options) do
    (options ++ @default_opts)
    |> Keyword.put(:encrypt, false)
    |> Plug.Session.init()
  end
end
