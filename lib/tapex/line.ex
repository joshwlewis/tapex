defmodule Tapex.Line do
  import Tapex.Tap, only: [{:spacecat, 2}, {:color_wrap, 3}]

  alias ExUnit.{Test,TestCase}

  def print_line(test, number, colorize) do
    format_line(test, number, colorize) |> IO.puts
  end

  def format_line(%TestCase{}=case, number, colorize) do
    {directive, directive_message} = get_directive(case)
    format_line(
      ok?(case),
      number,
      to_string(case.name),
      nil,
      directive,
      directive_message,
      colorize
    )
  end

  def format_line(%Test{}=test, number, colorize) do
    {directive, directive_message} = get_directive(test)
    format_line(
      ok?(test),
      number,
      to_string(test.name),
      to_string(test.case),
      directive,
      directive_message,
      colorize
    )
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
    |> spacecat(format_line_number number, colorize)
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

  defp get_directive(%{tags: %{skip: true}}) do
    {:skip, nil}
  end
  defp get_directive(%{tags: %{skip: reason}}) when is_binary(reason) do
    {:skip, reason}
  end
  defp get_directive(%{state: {:skip, reason}}) do
    {:skip, reason}
  end
  defp get_directive(%{tags: %{todo: true}}) do
    {:todo, nil}
  end
  defp get_directive(%{tags: %{todo: reason}}) when is_binary(reason) do
    {:todo, reason}
  end
  defp get_directive(%{}) do
    {nil, nil}
  end

  defp ok?(%{state: state}) do
    case state do
      nil -> true
      {:skip, _} -> true
      _ -> false
    end
  end
end
