defmodule PiviEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :pivi_ex,
      version: "0.1.1",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:csv, "~> 3.2"},
      {:uuid, "~> 1.1"},
      {:number, "~> 1.0"},
      {:sneeze, "~> 2.0"},
      {:decimal, "~> 2.1"}
    ]
  end
end
