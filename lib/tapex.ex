defmodule Tapex do

  use GenEvent

  alias ExUnit.{Formatter}
  alias Tapex.Tap

  import Tapex.Diagnostic
  import Tapex.Line
  import Tapex.Report

  def init(opts) do
    print_filters(Keyword.get(opts, :include, []), :include)
    print_filters(Keyword.get(opts, :exclude, []), :exclude)

    Tap.format_header |> IO.puts

    colorize = case get_in(opts, [:colors, :enabled]) do
      nil     -> IO.ANSI.enabled?
      enabled -> enabled
    end

    config = %{
      colorize: colorize,
      state_counter: %{},
      seed: opts[:seed],
      tag_counter: %{},
      test_count: 0,
      type_counter: %{}
    }

    {:ok, config}
  end

  def handle_event({:suite_finished, run_time, load_time}, %{test_count: count}=config) do
    IO.puts(Tap.format_plan(count))
    IO.puts("")
    IO.puts(Formatter.format_time(run_time, load_time))
    IO.puts(format_counts(config))

    :remove_handler
  end

  def handle_event({:test_finished, %{}=test}, %{colorize: colorize}=config) do
    %{test_count: number} = config = increment_counters(config, test)
    print_line(test, number, colorize)
    print_diagnostic(test, get_in(config, [:state_counter, :failed]) || 0, colorize)
    {:ok, config}
  end

  def handle_event({:case_finished, case}, %{colorize: colorize}=config) do
    %{test_count: number} = config = increment_counters(config, case)
    print_line(case, number, colorize)
    print_diagnostic(case, get_in(config, [:state_counter, :failed]) || 0, colorize)
    {:ok, config}
  end

  def handle_event(_, config) do
    {:ok, config}
  end

  defp increment_counters(%{}=config, %{}=test) do
    increment_test_count(config)
    |> increment_type_counter(test)
    |> increment_state_counter(test)
    |> increment_tag_counter(test)
  end

  defp increment_type_counter(%{type_counter: counter}=config, %{tags: %{type: type}}) do
    %{config | type_counter: Map.update(counter, type, 1, &(&1 + 1))}
  end

  defp increment_type_counter(%{}=config, %{}) do
    config
  end

  defp increment_state_counter(%{state_counter: counter}=config, %{state: {state, _}}) do
    %{config | state_counter: Map.update(counter, state, 1, &(&1 + 1))}
  end
  defp increment_state_counter(%{state_counter: counter}=config, %{state: nil}) do
    %{config | state_counter: Map.update(counter, :passed, 1, &(&1 + 1))}
  end
  defp increment_state_counter(%{}=config, %{}) do
    config
  end

  defp increment_tag_counter(%{tag_counter: counter}=config, %{tags: %{todo: todo}}) do
    case todo do
      false -> config
      nil   -> config
      _     -> %{config | tag_counter: Map.update(counter, :todo, 1, &(&1 + 1))}
    end
  end
  defp increment_tag_counter(%{}=config, %{}) do
    config
  end

  defp increment_test_count(%{test_count: count}=config) do
    %{config | test_count: count + 1}
  end

  defp print_filters([], _) do
    nil
  end
  defp print_filters(filters, type) do
    Formatter.format_filters(filters, type) |> IO.puts
  end
end
