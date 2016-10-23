defmodule Tapex.TapTest do
  use ExUnit.Case, async: true

  alias Tapex.Tap

  test "format_plan" do
    assert Tap.format_plan(0) == "1..0"
    assert Tap.format_plan(1) == "1..1"
    assert Tap.format_plan(101) == "1..101"
  end

  test "format_header" do
    assert Tap.format_header() == "TAP version 13"
  end

  test "format_line for pass" do
    result = Tap.format_line(true, 3, "MyTest", "is awesome", nil, nil, false)
    assert result == "ok 3 MyTest: is awesome"
  end

  test "format_line for fail" do
    result = Tap.format_line(false, 5, "OtherTest", "is lame", nil, nil, false)
    assert result == "not ok 5 OtherTest: is lame"
  end

  test "format_line with skip" do
    result = Tap.format_line(true, 5, "ATest", "is unspecific", :skip, nil, false)
    assert result == "ok 5 ATest: is unspecific # SKIP"
  end

  test "format_line with todo and message" do
    result = Tap.format_line(true, 12, "ThatTest", "double check", :todo, "fix", false)

    assert result == "ok 12 ThatTest: double check # TODO fix"
  end

  test "format_line with color" do
    result = Tap.format_line(true, 42, "SecretTest", "life the universe and everything", nil, nil, true)
    assert result == "\e[32mok\e[0m 42 SecretTest: \e[32mlife the universe and everything\e[0m"
  end
end
