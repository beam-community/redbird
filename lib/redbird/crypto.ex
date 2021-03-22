defmodule Redbird.Crypto do
  def sign_key(key, conn, opts \\ []) do
    case key_base(conn) do
      {:ok, base} -> Plug.Crypto.sign(base, signing_salt(), key, opts)
      error -> handle_error(error)
    end
  end

  def verify_key(key, conn, opts \\ []) do
    case key_base(conn) do
      {:ok, base} -> Plug.Crypto.verify(base, signing_salt(), key, opts)
      error -> handle_error(error)
    end
  end

  def safe_binary_to_term(b, opts \\ []) when is_binary(b) do
    Plug.Crypto.non_executable_binary_to_term(b, opts)
  end

  defp key_base(conn) do
    base = Application.get_env(:redbird, :key_base) || conn.secret_key_base
    (base && {:ok, base}) || {:error, :key_base_not_found}
  end

  @default_signing_salt "redbird"
  defp signing_salt do
    Application.get_env(:redbird, :signing_salt, @default_signing_salt)
  end

  defp handle_error({:error, :key_base_not_found}) do
    {
      :error,
      """
      A key base is required for signing keys.
      Set the key base in configuration or add a secret key base to the %Plug.Conn{}
      """
    }
  end

  defp handle_error(error) do
    error
  end
end
