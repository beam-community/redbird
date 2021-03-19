defmodule Redbird.Value do
  alias Redbird.Crypto

  def serialize(data) do
    :erlang.term_to_binary(data)
  end

  def deserialize(data) do
    Crypto.safe_binary_to_term(data)
  end
end
