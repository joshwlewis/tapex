defmodule Tapex.ReportTest do
  use ExUnit.Case, async: true

  import Tapex.Report

  test "format_counts/1 displays passed and failed" do
    conf = %{
      test_count: 4,
      state_counter: %{
        passed: 2,
        failed: 2,
      },
      tag_counter: %{}
    }

    result = format_counts(conf)

    assert result == "4 tests, 2 passed, 2 failed"
  end
end
