defmodule Tapex do

  use GenEvent

  alias ExUnit.{Formatter, Test, TestCase}
  alias Tapex.Tap

  import Tapex.Diagnostic
  import Tapex.Line

  def init(opts) do
    print_filters(Keyword.get(opts, :include, []), :include)
    print_filters(Keyword.get(opts, :exclude, []), :exclude)
    IO.puts("")

    config = %{
      seed: opts[:seed],
      trace: opts[:trace],
      colors: Keyword.put_new(opts[:colors], :enabled, IO.ANSI.enabled?),
      type_counter: %{},
      state_counter: %{},
      test_count: 0,
    }

    Tap.format_header |> IO.puts

    {:ok, config}
  end

  def handle_event({:suite_started, opts}, config) do
    Tap.format_plan(Dict.get(opts, :max_cases)) |> IO.puts
    {:ok, config}
  end

  def handle_event({:suite_finished, _, _}, _) do
    # TODO: print the suite summary
    :remove_handler
  end

  def handle_event({:test_finished, %{state: state}=test}, %{colors: [enabled: colorize]}=config) do
    %{test_count: number} = config = increment_counters(config, test)
    print_line(test, number, colorize)
    print_diagnostic(test, get_in(config, [:state_counter, :failed]) ||0, colorize)
    {:ok, config}
  end

  def handle_event({:case_finished, case}, %{colors: [enabled: colorize]}=config) do
    %{test_count: number} = config = increment_counters(config, case)
    print_line(case, number, colorize)
    {:ok, config}
  end

  def handle_event(_, config) do
    {:ok, config}
  end

  defp increment_counters(%{}=config, %{}=test) do
    increment_test_count(config)
    |> increment_type_counter(test)
    |> increment_state_counter(test)
  end

  defp increment_type_counter(%{type_counter: counter}=config, %{tags: %{type: type}}) do
    %{config | type_counter: Map.update(counter, type, 1, &(&1 + 1))}
  end

  defp increment_type_counter(%{}=config, %{}) do
    config
  end

  defp increment_state_counter(%{state_counter: counter}=config, %{state: state, tags: tags}) do
    counter = Map.update(counter, state || :passed, 1, &(&1 + 1))
    counter =
      case Map.get(tags, :todo) do
        nil -> counter
        _ -> Map.update(counter, :todo, 1, &(&1 + 1))
      end
    %{config | type_counter: counter}
  end

  defp increment_state_counter(%{}=config, %{}) do
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
