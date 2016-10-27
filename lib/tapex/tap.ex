defmodule Tapex.Tap do

  alias ExUnit.{Test,TestCase,Formatter}

  def format_plan(test_count), do: "1..#{test_count}"

  def format_header(), do: "TAP version 13"


  def format_diagnostic(%{state: {:failed, failures}}=test, number, colorize) do
    Formatter.format_test_failure(test, failures, number, :infinity, &diagnostic_formatter(&1, &2, colorize))
  end
  def format_diagnostic(_, _, _) do
    ""
  end

  defp diagnostic_formatter(_type, message, colorize) do
    color_wrap(to_string(message), :cyan, colorize)
  end

  def format_line(ok, number, name, case, directive, message, colorize) do
    message_color =
      case {ok, directive} do
        {_, :skip} -> :yellow
        {true, :todo} -> :cyan
        {false, :todo} -> :magenta
        {true, _} -> :green
        {false, _} -> :red
      end
    format_line_status(ok, colorize)
    |> spacecat(format_line_number number, colorize )
    |> spacecat(format_line_description name, case, message_color, colorize)
    |> spacecat(format_line_directive directive, message, colorize)
  end

  defp format_line_status(true, colorize) do
    color_wrap("ok", :green, colorize)
  end
  defp format_line_status(false, colorize) do
    color_wrap("not ok", :red, colorize)
  end

  defp format_line_number(nil, colorize), do: nil
  defp format_line_number(number, colorize), do: to_string(number)

  defp format_line_description(nil, case, color, colorize) do
    color_wrap(case, color, colorize)
  end
  defp format_line_description(name, nil, color, colorize) do
    color_wrap(name, color, colorize)
  end
  defp format_line_description(name, case, color, colorize) do
    color_wrap(name, color, colorize) |> spacecat("(#{case})")
  end

  defp format_line_directive(nil, _, _), do: nil
  defp format_line_directive(:skip, message, colorize) do
    "# " <> color_wrap("SKIP", :yellow, colorize) |> spacecat(message)
  end
  defp format_line_directive(:todo, message, colorize) do
    "# " <> color_wrap("TODO", :blue, colorize) |> spacecat(message)
  end

  defp spacecat(first_string, nil), do: first_string
  defp spacecat(first_string, ""), do: first_string
  defp spacecat(first_string, second_string) do
    first_string <> " " <> second_string
  end

  defp color_wrap(string, color, enabled) do
    [color | string]
    |> IO.ANSI.format(enabled)
    |> IO.iodata_to_binary
  end
end
