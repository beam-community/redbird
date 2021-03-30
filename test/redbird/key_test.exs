defmodule Redbird.KeyTest do
  use ExUnit.Case, async: false

  alias Redbird.{Crypto, Key}

  describe "generate/0" do
    test "generates a random key" do
      expected = ~r/[A-Za-z0-9\/\+\=]{128}/

      actual = Key.generate()

      assert actual =~ expected
    end
  end

  describe "generate/1" do
    test "generates a random string prefixed by a namespace" do
      namespace = "redbird_"
      expected = ~r/#{namespace}[A-Za-z0-9\/\+\=]{128}/

      actual = Key.generate(namespace)

      assert actual =~ expected
    end
  end

  describe "namespace/0" do
    setup do
      on_exit(fn -> Application.delete_env(:redbird, :key_namespace) end)
    end

    test "provides the default namespace when it is not set in the env" do
      expected = "redbird_session_"

      actual = Key.namespace()

      assert actual == expected
    end

    test "provides the namespace set in the env" do
      expected = "user_set_namespace_"

      Application.put_env(:redbird, :key_namespace, expected)

      actual = Key.namespace()

      assert actual == expected
    end
  end

  describe "extract_key/1" do
    test "extracts the key from the namespace when is contains the namespace" do
      expected_namespace = Key.namespace()
      expected_key = "abcdef1234"

      actual = Key.extract_key(expected_namespace <> expected_key)

      assert {:ok, ^expected_key, ^expected_namespace} = actual
    end

    test "extracts the key when it does not contain the namespace" do
      expected_key = "abcdef1234"

      actual = Key.extract_key(expected_key)

      assert {:ok, ^expected_key, nil} = actual
    end

    test "provides an error for nil keys" do
      actual = Key.extract_key(nil)

      assert {:error, :unusable_key, nil} = actual
    end
  end

  describe "sign_key/2" do
    test "signs the key without signing the namespace" do
      conn = Redbird.ConnCase.signed_conn()
      generated_key = Key.generate(Key.namespace())
      {:ok, original_key, expected_namespace} = Key.extract_key(generated_key)

      actual = Key.sign_key(generated_key, conn)
      {:ok, actual_key, actual_namespace} = Key.extract_key(actual)

      assert expected_namespace == actual_namespace
      assert original_key != actual_key
      assert {:ok, _} = Crypto.verify_key(actual_key, conn)
    end

    test "signs the key when it does not include a namespace" do
      conn = Redbird.ConnCase.signed_conn()
      generated_key = Key.generate("")
      {:ok, original_key, expected_namespace} = Key.extract_key(generated_key)

      actual = Key.sign_key(generated_key, conn)
      {:ok, actual_key, actual_namespace} = Key.extract_key(actual)

      assert expected_namespace == actual_namespace
      assert actual_namespace == nil
      assert original_key != actual_key
      assert {:ok, _} = Crypto.verify_key(actual_key, conn)
    end
  end

  describe "accessible?/2" do
    test "verifiable keys with a namespace are accessible" do
      conn = Redbird.ConnCase.signed_conn()
      generated_key = Key.generate(Key.namespace())
      signed_key = Key.sign_key(generated_key, conn)

      actual = Key.accessible?(signed_key, conn)

      assert actual == true
    end

    test "verifiable keys without a namespace are accessible" do
      conn = Redbird.ConnCase.signed_conn()
      generated_key = Key.generate("")
      signed_key = Key.sign_key(generated_key, conn)

      actual = Key.accessible?(signed_key, conn)

      assert actual == true
    end

    test "non-verifiable keys are not-accessible" do
      conn = Redbird.ConnCase.signed_conn()
      generated_key = Key.generate("")
      signed_key = Key.sign_key(generated_key, conn)
      tampered_key = signed_key <> "sneaky"

      actual = Key.accessible?(tampered_key, conn)

      assert actual == false
    end
  end
end
