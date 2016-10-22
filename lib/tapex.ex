defmodule Tapex do

  use GenEvent

  import ExUnit.Formatter, only: [format_filters: 2]

  def init(opts) do
    print_filters(Keyword.get(opts, :include), :include)
    print_filters(Keyword.get(opts, :exclude), :exclude)

    IO.puts("TAP version 13")

    config = %{
      seed: opts[:seed],
      trace: opts[:trace],
      pass_count: 0,
      fail_count: 0,
      skip_count: 0
    }
    {:ok, config}
  end

  def handle_event({:suite_started, opts}, config) do
    print_plan(Dict.get(opts, :max_cases))
    {:ok, config}
  end

  def handle_event({:suite_finished, run_us, load_us}, config) do
    :remove_handler
  end

  def handle_event({:test_started, %ExUnit.Test{} = test}, config) do
    {:ok, config}
  end

  # pass
  def handle_event({:test_finished, %ExUnit.Test{state: nil} = test}, config) do
    {:ok, config}
  end

  # skip
  def handle_event({:test_finished, %ExUnit.Test{state: {:skip, _}} = test}, config) do
    {:ok, config}
  end

  # invalid
  def handle_event({:test_finished, %ExUnit.Test{state: {:invalid, _}} = test}, config) do
    {:ok, config}
  end

  # fail
  def handle_event({:test_finished, %ExUnit.Test{state: {:failed, failures}} = test}, config) do
    {:ok, config}
  end

  def handle_event({:case_started, %ExUnit.TestCase{name: name}}, config) do
    {:ok, config}
  end

  def handle_event({:case_finished, %ExUnit.TestCase{state: nil}}, config) do
    {:ok, config}
  end

  def handle_event({:case_finished, %ExUnit.TestCase{state: {:failed, failures}} = test_case}, config) do
    {:ok, config}
  end


  def print_filters(nil, _type), do: nil
  def print_filters([], _type), do: nil
  def print_filters(filters, type) do
    IO.puts format_filters(filters, type)
  end

  defp print_plan(nil), do: nil
  defp print_plan(0), do: nil
  defp print_plan(count) do
    IO.puts "1..#{count}"
  end
end
