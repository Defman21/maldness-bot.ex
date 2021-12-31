defmodule MaldnessBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :maldness_bot,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {MaldnessBot.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:finch, "~> 0.9"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.0"}
    ]
  end
end
