defmodule Mix.Tasks.Redbird.DeleteAllSessions do
  @moduledoc """
  Deletes all redbird sessions.

  ## Example

      mix redbird.delete_all_sessions my_app

  The first argument is the app specific key_namespace you set in your plug
  session config. If no argument is given, it will delete all redbird sessions.
  """

  use Mix.Task

  @shortdoc "Deletes all redbird sessions"

  def run(_args) do
    Application.ensure_started(:redbird)

    delete_all_sessions(Redbird.Key.namespace())
  end

  def delete_all_sessions(namespace) do
    "#{namespace}*"
    |> Redbird.Redis.keys()
    |> Redbird.Redis.del()
  end
end
