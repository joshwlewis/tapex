defmodule Tapex do

  use GenEvent

  alias ExUnit.{Formatter, Test, TestCase}

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

    IO.puts("TAP version 13")

    {:ok, config}
  end

  def handle_event({:suite_started, opts}, config) do
    print_plan(Dict.get(opts, :max_cases))
    {:ok, config}
  end

  def handle_event({:suite_finished, _, _}, _) do
    # TODO: print the suite summary
    :remove_handler
  end

  def handle_event({:test_finished, %Test{}=test}, config) do
    config = increment_counters(config, test)
    format_line(test, Map.get(config, :test_count)) |> IO.puts
    {:ok, config}
  end

  def handle_event({:case_finished, case}, config) do
    config = increment_counters(config, case)
    format_line(case, Map.get(config, :test_count)) |> IO.puts
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

  defp print_plan(nil), do: nil
  defp print_plan(0) do
    IO.puts "1..0"
  end
  defp print_plan(count) do
    IO.puts "1..#{count + 1}"
  end

  defp format_line(true), do: "ok"
  defp format_line(false), do: "not ok"

  defp format_line(%TestCase{}=case, number) do
    {directive, directive_message} = get_directive(case)
    format_line(
      ok?(case),
      number,
      case.name,
      nil,
      directive,
      directive_message
    )
  end

  defp format_line(%Test{}=test, number) do
    {directive, directive_message} = get_directive(test)
    format_line(
      ok?(test),
      number,
      test.case,
      test.name,
      directive,
      directive_message
    )
  end

  defp format_line(ok, nil), do: format_line(ok)
  defp format_line(ok, num), do: format_line(ok) <> " #{num}"

  defp format_line(ok, num, nil), do: format_line(ok, num)
  defp format_line(ok, num, msg), do: format_line(ok, num) <> " #{msg}"

  defp format_line(ok, num, nil, test), do: format_line(ok, num, test)
  defp format_line(ok, num, kase, nil), do: format_line(ok, num, kase)
  defp format_line(ok, num, kase, test), do: format_line(ok, num, "#{kase}: #{test}")

  defp format_line(ok, num, kase, test, nil) do
    format_line(ok, num, kase, test)
  end
  defp format_line(ok, num, kase, test, directive) do
    directive = to_string(directive) |> String.upcase()
    format_line(ok, num, kase, test) <> " # #{directive}"
  end

  defp format_line(ok, num, kase, test, directive, nil) do
    format_line(ok, num, kase, test, directive)
  end
  defp format_line(ok, num, kase, test, directive, true) do
    format_line(ok, num, kase, test, directive)
  end
  defp format_line(ok, num, kase, test, _, false) do
    format_line(ok, num, kase, test, nil)
  end
  defp format_line(ok, num, kase, test, directive, directive_message) do
    format_line(ok, num, kase, test, directive) <> " #{directive_message}"
  end

  defp get_directive(%{tags: tags}) do
    case tags do
      %{skip: message} -> {:skip, message}
      %{todo: message} -> {:todo, message}
      _                -> {nil, nil}
    end
  end

  defp get_directive(%{state: state}) do
    if state == :skip do
      {:skip, true}
    else
      {nil, nil}
    end
  end

  defp ok?(%{state: state}) do
    case state do
      nil -> true
      {:skip, _} -> true
      _ -> false
    end
  end

end
