defmodule Tapex.Tap do

  alias ExUnit.{Test,TestCase,Formatter}

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
end
