defmodule Tapex.ReportTest do
  use ExUnit.Case, async: true

  import Tapex.Report

  test "format_counts/1 displays passed failed and skipped" do
    conf = %{
      colorize: false,
      test_count: 4,
      state_counter: %{
        passed: 2,
        failed: 0,
        skip: 1,
      },
      tag_counter: %{}
    }

    result = format_counts(conf)

    assert result == "4 tests, 2 passed, 0 failed, 1 skipped"
  end

  test "format_counts displays colors when enabled" do
    conf = %{
      colorize: true,
      test_count: 5,
      state_counter: %{
        passed: 1,
        failed: 2,
        invalid: 1,
      },
      tag_counter: %{}
    }

    result = format_counts(conf)

    expected = "\e[31m5 tests\e[0m, \e[31m1 passed\e[0m, \e[31m2 failed\e[0m, \e[33m1 invalid\e[0m"

    assert result  == expected
  end
end
