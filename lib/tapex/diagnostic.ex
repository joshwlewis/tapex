defmodule Tapex.Diagnostic do

  alias ExUnit.Formatter

  import Tapex.Tap, only: [{:color_wrap, 3}]

  def format_diagnostic(%{state: {:failed, failures}}=test, number, colorize) do
    Formatter.format_test_failure(test, failures, number, :infinity, &formatter(&1, &2, colorize))
  end

  def format_diagnostic(_, _, _) do
    ""
  end

  defp formatter(_type, message, colorize) do
    color_wrap(to_string(message), :cyan, colorize)
  end
end
