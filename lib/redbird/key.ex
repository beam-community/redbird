defmodule Redbird.Key do
  @moduledoc """
  Key helper functions for Redbird.
  """

  alias Redbird.Crypto

  @default_namespace "redbird_session_"

  @default_bytes_count 96
  def generate(namespace \\ namespace(), bytes_count \\ @default_bytes_count) do
    namespace <> (bytes_count |> :crypto.strong_rand_bytes() |> Base.encode64())
  end

  def sign_key(key, conn) do
    {:ok, key, namespace} = extract_key(key)
    to_string(namespace) <> Crypto.sign_key(key, conn)
  end

  def accessible?(key, conn, opts \\ []) do
    with {:ok, key, _} <- extract_key(key),
         {:ok, _verified_key} <- Crypto.verify_key(key, conn, opts) do
      true
    else
      _ -> false
    end
  end

  def extract_key(candidate) when is_binary(candidate) do
    case String.split(candidate, namespace(), parts: 2) do
      [key] -> {:ok, key, nil}
      [_, key] -> {:ok, key, namespace()}
    end
  end

  def extract_key(nil) do
    {:error, :unusable_key, nil}
  end

  def namespace do
    Application.get_env(:redbird, :key_namespace, @default_namespace)
  end
end
