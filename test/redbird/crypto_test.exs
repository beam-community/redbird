defmodule Redbird.CryptoTest do
  use Redbird.ConnCase, async: false

  alias Redbird.Crypto

  describe "sign_key/3" do
    setup do
      on_exit(fn -> Application.delete_env(:redbird, :key_base) end)
    end

    test "signs the key with configured key base" do
      Application.put_env(:redbird, :key_base, "abcdef12345")

      conn = Plug.Test.conn(:get, "/")
      key = "somerediskey"

      actual = Crypto.sign_key(key, conn)

      refute actual =~ key
      assert {:ok, ^key} = Crypto.verify_key(actual, conn)
    end

    test "signs the key with the conn secret key base when configured key base is not set" do
      conn = signed_conn()
      key = "somerediskey"

      actual = Crypto.sign_key(key, conn)

      refute actual =~ key
      assert {:ok, ^key} = Crypto.verify_key(actual, conn)
    end

    test "errors when configured key base is not set and conn does not have secret key base" do
      conn = Plug.Test.conn(:get, "/")
      key = "somerediskey"

      actual = Crypto.sign_key(key, conn)

      assert {:error, message} = actual
      assert message =~ ~r/key base is required/i
    end
  end

  describe "verify_key/3" do
    test "verifies keys signed using the secret key base and signing salt" do
      conn = signed_conn()
      key = "somerediskey"
      signed_key = Crypto.sign_key(key, conn)

      assert {:ok, ^key} = Crypto.verify_key(signed_key, conn)
    end

    test "invalidates keys signed using another secret key base" do
      conn = signed_conn()
      key = "somerediskey"
      signed_key = Crypto.sign_key(key, conn)
      another_conn = signed_conn()

      assert {:error, :invalid} = Crypto.verify_key(signed_key, another_conn)
    end

    test "invalidates keys that have been tampered with" do
      conn = signed_conn()
      key = "somerediskey"
      signed_key = Crypto.sign_key(key, conn)
      tampered_key = tamper_with_key(signed_key)

      assert {:error, :invalid} = Crypto.verify_key(tampered_key, conn)
    end
  end

  describe "safe_binary_to_term/1" do
    test "translates a binary to terms" do
      expected = %{hello: "world"}
      binary = :erlang.term_to_binary(expected)

      actual = Crypto.safe_binary_to_term(binary)

      assert expected == actual
    end

    test "safely translates what would otherwise be unsafe terms" do
      expected = fn -> raise "Elixir go boom!" end
      binary = :erlang.term_to_binary(expected)

      assert_raise ArgumentError, fn ->
        Crypto.safe_binary_to_term(binary)
      end
    end
  end

  defp tamper_with_key(key) do
    [first | other] = String.graphemes(key)
    Enum.join([other, first])
  end
end
