defmodule Tapex.Tap do

  def format_plan(test_count), do: "1..#{test_count}"

  def format_header(), do: "TAP version 13"

  def spacecat(first_string, nil), do: first_string
  def spacecat(first_string, ""), do: first_string
  def spacecat(first_string, second_string) do
    first_string <> " " <> second_string
  end

  def color_wrap(string, color, enabled) do
    [color | string]
    |> IO.ANSI.format(enabled)
    |> IO.iodata_to_binary
  end

  def leftpad(string, count) do
    space(count-String.length(string)) <> string
  end

  def rightpad(string, count) do
    string <> space(count-String.length(string))
  end

  def space(n) when n > 0, do: " " <> space(n-1)
  def space(_), do: ""
end
