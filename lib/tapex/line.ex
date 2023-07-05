defmodule Tapex.Line do
  import Tapex.Tap, only: [{:leftpad, 2}, {:rightpad, 2}, {:spacecat, 2}, {:color_wrap, 3}]

  def print_line(test, number, colorize) do
    format_line(test, number, colorize) |> IO.puts
  end

  def format_line(%{}=test, number, colorize) do
    ok = ok?(test)
    {directive, message} = get_directive(test)

    name = Map.get(test, :name)
    case = Map.get(test, :case)

    message_color =
      case {ok, directive} do
        {_, :skip} -> :yellow
        {true, :todo} -> :cyan
        {false, :todo} -> :magenta
        {true, _} -> :green
        {false, _} -> :red
      end

    format_line_status(ok, colorize)
    <> format_line_number(number)
    |> spacecat(format_line_description name, case, message_color, colorize)
    |> spacecat(format_line_directive directive, message, colorize)
  end

  defp format_line_status(true, colorize) do
    rightpad("ok", 6)
    |> color_wrap(:green, colorize)
  end
  defp format_line_status(false, colorize) do
    rightpad("not ok", 6)
    |> color_wrap(:red, colorize)
  end

  defp format_line_number(number),
    do: leftpad(to_string(number), 4)

  defp format_line_description(nil, case, color, colorize) do
    color_wrap(to_string(case), color, colorize)
  end
  defp format_line_description(name, nil, color, colorize) do
    color_wrap(to_string(name), color, colorize)
  end
  defp format_line_description(name, case, color, colorize) do
    color_wrap(to_string(name), color, colorize) |> spacecat("(#{case})")
  end

  defp format_line_directive(nil, _, _), do: nil
  defp format_line_directive(:skip, message, colorize) do
    "# " <> color_wrap("SKIP", :yellow, colorize) |> spacecat(message)
  end
  defp format_line_directive(:todo, message, colorize) do
    "# " <> color_wrap("TODO", :blue, colorize) |> spacecat(message)
  end

  defp get_directive(%{state: {:excluded, reason}}) when is_binary(reason) do
    {:skip, reason}
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
      {:excluded, _} -> true
      _ -> false
    end
  end
end
