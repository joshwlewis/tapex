defmodule Tapex.Report do

  import Tapex.Tap, only: [{:color_wrap, 3}]

  def format_counts(%{test_count: count, state_counter: states, tag_counter: tags}) do
    colorize = false
    color = :green
    [
      format_count(count, color, colorize),
      format_passed(states, color, colorize),
      format_failed(states, color, colorize),
      format_invalid(states, colorize),
      format_skipped(states, colorize),
      format_todo(tags, colorize),
    ]
    |> Enum.filter(fn (v) -> v end)
    |> Enum.join(", ")
  end

  def format_count(1, color, colorize),
    do: color_wrap("1 test", color, colorize)
  def format_count(n, color, colorize),
    do: color_wrap("#{n} tests", color, colorize)

  def format_passed(%{passed: 0}, _color, colorize),
    do: color_wrap("0 passed", :red, colorize)
  def format_passed(%{passed: n}, color, colorize),
    do: color_wrap("#{n} passed", color, colorize)
  def format_passed(%{}, _color, colorize),
    do: color_wrap("0 passed", :red, colorize)

  def format_failed(%{failed: 0}, color, colorize),
    do: color_wrap("0 failed", color, colorize)
  def format_failed(%{failed: n}, _color, colorize),
    do: color_wrap("#{n} failed", :red, colorize)
  def format_failed(_counter, color, colorize),
    do: color_wrap("0 failed", color, colorize)

  def format_invalid(%{invalid: 0}, _colorize),
    do: nil
  def format_invalid(%{invalid: n}, colorize),
    do: color_wrap("#{n} invalid", :yellow, colorize)
  def format_invalid(_counter, _colorize),
    do: nil

  def format_skipped(%{skipped: 0}, _colorize),
    do: nil
  def format_skipped(%{skipped: n}, colorize),
    do: color_wrap("#{n} skipped", :yellow, colorize)
  def format_skipped(_counter, _colorize),
    do: nil

  def format_todo(%{todo: 0}, _colorize),
    do: nil
  def format_todo(%{todo: n}, colorize),
    do: color_wrap("#{n} todo", :blue, colorize)
  def format_todo(_counter, _colorize),
    do: nil
end
