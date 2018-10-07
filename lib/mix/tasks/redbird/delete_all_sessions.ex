defmodule Mix.Tasks.Redbird.DeleteAllSessions do
  use Mix.Task

  @shortdoc "Deletes all redbird sessions"

  @moduledoc """
  Deletes all redbird sessions.
      mix redbird.delete_all_sessions my_app
  The first argument is the app specific key_namespace you set in your plug
  session config. If no argument is given, it will delete all redbird sessions.
  """
  def run(_args) do
    Application.ensure_started(:redbird)

    Plug.Session.REDIS.namespace()
    |> delete_all_sessions
  end

  def delete_all_sessions(namespace) do
    Redbird.Redis.keys("#{namespace}*")
    |> Redbird.Redis.del()
  end
end
