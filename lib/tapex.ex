defmodule Tapex do

  use GenEvent

  alias ExUnit.{CLIFormatter, Formatter, Test, TestCase}

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

  def handle_event({:suite_finished, _, _} = args, config) do
    :remove_handler
  end

  def handle_event({:test_finished, %Test{}=test}, config) do
    number = Map.get(config, :test_count, 0) + 1
    format_tap(test, number) |> IO.puts
    config = increment_test_count(config)
             |> increment_type_counter(test)
             |> increment_state_counter(test)
    {:ok, config}
  end

  def handle_event({:case_finished, %TestCase{}=case}, config) do
    number = Map.get(config, :test_count, 0) + 1
    format_tap(case, number) |> IO.puts
    config = increment_test_count(config)
             |> increment_type_counter(case)
             |> increment_state_counter(case)
    {:ok, config}
  end

  def handle_event(_, config) do
    {:ok, config}
  end

  defp increment_type_counter(%{type_counter: counter}=config, %{tags: %{type: type}}) do
    %{config | type_counter: Map.update(counter, type, 1, &(&1 + 1))}
  end

  defp increment_type_counter(%{}=config, %{}) do
    config
  end

  defp increment_state_counter(%{state_counter: counter}=config, %{state: state, tags: tags}) do
    counter = Map.update(counter, state || :passed, 1, &(&1 + 1))
    if Map.get(tags, :todo) do
      counter = Map.update(counter, :todo, 1, &(&1 + 1))
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
  defp print_plan(0), do: nil
  defp print_plan(count) do
    IO.puts "1..#{count + 1}"
  end

  defp format_tap(%TestCase{}=case, number) do
    {directive, directive_message} = get_directive(case)
    format_test(
      (case.state == nil || case.state == :skipped),
      number,
      case.name,
      nil,
      directive,
      directive_message
    )
  end

  defp format_tap(%Test{}=test, number) do
    {directive, directive_message} = get_directive(test)
    format_test(
      (test.state == nil || test.state == :skipped),
      number,
      test.case,
      test.name,
      directive,
      directive_message
    )
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
      {:skip, nil}
    else
      {nil, nil}
    end
  end

  defp format_test(true), do: "ok"
  defp format_test(false), do: "not ok"

  defp format_test(ok, nil), do: format_test(ok)
  defp format_test(ok, num), do: format_test(ok) <> " #{num}"

  defp format_test(ok, num, nil), do: format_test(ok, num)
  defp format_test(ok, num, msg), do: format_test(ok, num) <> " #{msg}"

  defp format_test(ok, num, nil, test), do: format_test(ok, num, test)
  defp format_test(ok, num, kase, nil), do: format_test(ok, num, kase)
  defp format_test(ok, num, kase, test), do: format_test(ok, num, "#{kase}: #{test}")

  defp format_test(ok, num, kase, test, nil) do
    format_test(ok, num, kase, test)
  end
  defp format_test(ok, num, kase, test, directive) do
    format_test(ok, num, kase, test) <> " ##{directive}"
  end

  defp format_test(ok, num, kase, test, directive, nil) do
    format_test(ok, num, kase, test, directive)
  end
  defp format_test(ok, num, kase, test, directive, false) do
    format_test(ok, num, kase, test, nil)
  end
  defp format_test(ok, num, kase, test, directive, directive_message) do
    format_test(ok, num, kase, test, directive) <> " #{directive_message}"
  end
end
