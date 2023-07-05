defmodule Tapex.LineTest do
  use ExUnit.Case, async: true

  import Tapex.Line

  test "format_line for pass" do
    test = %{
      state: nil,
      case: "MyTest",
      name: "is awesome",
    }
    result = format_line(test, 3, false)
    assert result == "ok       3 is awesome (MyTest)"
  end

  test "format_line for fail" do
    test = %{
      state: {:fail, []},
      case: "OtherTest",
      name: "is lame"
    }

    result = format_line(test, 5, false)
    assert result == "not ok   5 is lame (OtherTest)"
  end

  test "format_line with skip" do
    test = %{
      state: nil,
      case: "ATest",
      name: "is unspecific",
      tags: %{skip: true},
    }

    result = format_line(test, 5, false)
    assert result == "ok       5 is unspecific (ATest) # SKIP"
  end

  test "format_line with exclude" do
    test = %{
      case: "ATest",
      name: "is unspecific",
      state: {:excluded, "due to integration filter"},
      tags: %{}
    }

    result = format_line(test, 5, false)
    assert result == "ok       5 is unspecific (ATest) # SKIP due to integration filter"
  end

  test "format_line with todo and message" do
    test = %{
      state: nil,
      case: "ThatTest",
      name: "double check",
      tags: %{todo: "fix"}
    }

    result = format_line(test, 12, false)
    assert result == "ok      12 double check (ThatTest) # TODO fix"
  end

  test "format_line with color" do
    test = %{
      state: nil,
      case: "SecretTest",
      name: "life the universe and everything",
    }

    result = format_line(test, 42, true)
    assert result == "\e[32mok    \e[0m  42 \e[32mlife the universe and everything\e[0m (SecretTest)"
  end
end
