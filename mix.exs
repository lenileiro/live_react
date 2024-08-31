defmodule LiveReact.MixProject do
  use Mix.Project

  def project do
    [
      app: :live_react,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    "A library for seamlessly integrating React components with Phoenix LiveView."
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix_live_view, "~> 0.18.0"},
      {:jason, "~> 1.2"},
      {:floki, ">= 0.30.0", only: :test},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false}
    ]
  end
end
