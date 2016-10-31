defmodule Tapex.Diagnostic do

  alias ExUnit.{Test,TestCase}

  import ExUnit.Formatter, only: [
    {:format_test_failure, 5}, 
    {:format_test_case_failure, 5}
  ]
  import Tapex.Tap, only: [{:color_wrap, 3}]

  def print_diagnostic(test, number, color) do
    case format_diagnostic(test, number, color) do
      nil -> :ok
      msg -> IO.puts(msg)
    end
  end

  def format_diagnostic(%Test{state: {:failed, failures}}=test, number, color) do
    format_test_failure(test, failures, number, :infinity, &formatter(&1, &2, color))
    |> diagnosticify()
  end

  def format_diagnostic(%TestCase{state: {:failed, failures}}=case, number, color) do
    format_test_case_failure(case, failures, number, :infinity, &formatter(&1, &2, color))
    |> diagnosticify()
  end

  def format_diagnostic(_test, _number, _color), do: nil

  defp formatter(:diff_enabled?, _, color), do: color
  defp formatter(:test_info, msg, _color), do: msg
  defp formatter(:error_info, msg, color),
    do: color_wrap(msg, :red, color)
  defp formatter(:extra_info, msg, color),
    do: color_wrap(msg, :cyan, color)
  defp formatter(:location_info, msg, color),
    do: color_wrap(msg, [:bright, :black], color)
  defp formatter(:diff_delete, msg, color),
    do: color_wrap(msg, :red, color)
  defp formatter(:diff_insert, msg, color),
    do: color_wrap(msg, :green, color)
  defp formatter(_type,  msg, _config), do: msg

  # Prepends each line of a message with the diagnostic indicator
  defp diagnosticify(message) when is_binary(message) do
    String.split(message, "\n")
    |> Enum.reject(&(String.strip(&1) == ""))
    |> Enum.map_join("\n", &("#     " <> &1))
  end
end
