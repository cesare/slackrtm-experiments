defmodule SlackRtm.MixProject do
  use Mix.Project

  def project do
    [
      app: :slack_rtm,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {SlackRtm.Application, [System.get_env("SLACK_TOKEN")]}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.1"},
      {:poison, "~> 3.1"},
      {:socket, "~> 0.3.13"},
      {:uri, "~> 0.1.0"},
    ]
  end
end
