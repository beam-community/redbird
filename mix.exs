defmodule Redbird.Mixfile do
  use Mix.Project

  def project do
    [
      app: :redbird,
      build_embedded: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      version: "0.7.1",
      package: package(),
      description: "A Redis adapter for Plug.Session",
      source_url: "https://github.com/beam-community/redbird"
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
      # Runtime dependencies
      {:plug, "~> 1.18"},
      {:redix, "~> 1.5"},

      # Dev and Test dependencies
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.30", only: :dev},
      {:mock, "~> 0.3", only: :test}
    ]
  end

  defp docs do
    [
      extras: ["README.md", "CHANGELOG.md", "LICENSE"],
      main: "readme"
    ]
  end

  defp package do
    [
      maintainers: ["BEAM Community"],
      files: ~w(lib mix.exs .formatter.exs README.md CHANGELOG.md LICENSE),
      licenses: ["MIT"],
      links: %{
        Changelog: "https://github.com/beam-community/redbird/releases",
        GitHub: "https://github.com/beam-community/redbird"
      }
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
