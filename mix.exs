defmodule Tapex.Mixfile do
  use Mix.Project

  def project do
    [app: :tapex,
     deps: deps(),
     description: description(),
     elixir: "~> 1.2",
     package: package(),
     version: "0.1.1"]
  end

  def application do
    []
  end

  defp description do
    "Tapex is a TAP (Test Anything Protocol) formatter for ExUnit."
  end

  defp package do
    [
      maintainers: ["Josh W Lewis"],
      licenses:    ["MIT"],
      links:       %{"GitHub" => "https://github.com/joshwlewis/tapex"}
    ]
  end

  defp deps do
    [{:ex_doc, "~> 0.14", only: :dev}]
  end
end
