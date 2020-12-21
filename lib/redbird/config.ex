defmodule Redbird.Config do
  def redis_options(options \\ []) do
    redis_opts = Keyword.merge(options, application_config_options())
    url = redis_opts[:url]
    opts = Keyword.delete(redis_opts, :url)

    if url do
      {url, opts}
    else
      opts
    end
  end

  defp application_config_options do
    Application.get_env(:redbird, :redis_options, [])
  end
end
