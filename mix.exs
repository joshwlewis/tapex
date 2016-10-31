defmodule Tapex.Mixfile do
  use Mix.Project

  def project do
    [app: :tapex,
     description: "Tapex is a TAP (Test Anything Protocol) formatter for ExUnit.",
     version: "0.1.0",
     elixir: "~> 1.2",
     deps: deps()]
  end

  def application do
    []
  end

  defp deps do
    []
  end

  def package do
    [
      maintainers: ["Josh W Lewis"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/joshwlewis/tapex"}
    ]
  end
end
