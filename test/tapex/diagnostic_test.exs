defmodule Tapex.DiagnosticTest do
  use ExUnit.Case, async: true

  import Tapex.Diagnostic

  test "format_diagnostic for test without color" do
    trace = [{Tapex, :awesome, 1, [file: 'awesome.ex', line: 42]}]
    failure = %ExUnit.AssertionError{
      expr: "Awesum!()",
      message: "not awesome"
    }
    test = %ExUnit.Test{
      state: {:failed, [{:error, failure, trace}]},
      name: "everything is awesome",
      tags: [file: "awesome.ex", line: 12]
    }
    actual = format_diagnostic(test, 2, false)

    expected =
      "#      2) everything is awesome (nil)\n" <>
      "#         awesome.ex:12\n" <>
      "#         not awesome\n" <>
      "#         code: Awesum!()\n" <>
      "#         stacktrace:\n" <>
      "#           (tapex) awesome.ex:42: Tapex.awesome/1"

    assert expected == actual
  end

  test "format_diagnostic for TestCase with color" do
    error = %RuntimeError{message: "BOOM!"}
    trace = [{Tapex, :my_method, 1, [file: 'my_module.ex', line: 20]}]
    case = %ExUnit.TestCase{
      state: {:failed, [{:error, error, trace}]}
    }

    actual = format_diagnostic(case, 5, true)

    expected =
      "#      5) nil: failure on setup_all callback, tests invalidated\n" <>
      "#         \e[31m** (RuntimeError) BOOM!\e[0m\n" <>
      "#         \e[36mstacktrace:\e[0m\n" <>
      "#           (tapex) my_module.ex:20: Tapex.my_method/1"

    assert expected == actual
  end
end
