defmodule Redbird.Mixfile do
  use Mix.Project
  @version "0.5.0"

  def project do
    [
      app: :redbird,
      build_embedded: Mix.env() == :prod,
      deps: deps(),
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      version: @version,
      package: [
        maintainers: ["anellis", "drapergeek"],
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/thoughtbot/redbird"}
      ],
      description: "A Redis adapter for Plug.Session",
      source_url: "https://github.com/thoughtbot/redbird",
      docs: [extras: ["README.md"], main: "readme"]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Redbird, []}
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.19.1", only: :dev},
      {:mock, "~> 0.3", only: :test},
      {:redix, "~> 1.0.0"},
      {:plug, "~> 1.1"}
    ]
  end
end
