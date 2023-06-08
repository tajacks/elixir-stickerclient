defmodule StickerClient.MixProject do
  use Mix.Project

  def project do
    [
      app: :stickerclient,
      description: "An Elixir library for interfacing with the Signal Stickers API",
      version: "0.2.0",
      source_url: "https://github.com/tajacks/elixir-stickerclient",
      homepage_url: "https://github.com/tajacks/elixir-stickerclient",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      dialyzer: [
        ignore_warnings: ".dialyzer_ignore.exs",
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
        flags: [:error_handling, :unknown],
        # Error out when an ignore rule is no longer useful so we can remove it
        list_unused_filters: true
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {StickerClient.Runtime.Application, []}
    ]
  end

  defp deps do
    [
      {:hkdf, "~> 0.2.0"},
      {:req, "~> 0.3.6"},
      {:protobuf, "~> 0.11.0"},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
      {:mox, "~> 1.0.2", only: :test},
      {:dialyxir, "~> 1.2", only: [:dev, :test], runtime: false}
    ]
  end

  defp package do
    [
      name: "stickerclient",
      licenses: ["LGPL-3.0-only"],
      links: %{"GitHub" => "https://github.com/tajacks/elixir-stickerclient"}
    ]
  end
end
