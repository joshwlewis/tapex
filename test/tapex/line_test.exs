defmodule Tapex.LineTest do
  use ExUnit.Case, async: true

  import Tapex.Line

  test "format_line for pass" do
    result = format_line(true, 3, "is awesome", "MyTest", nil, nil, false)
    assert result == "ok 3 is awesome (MyTest)"
  end

  test "format_line for fail" do
    result = format_line(false, 5, "is lame", "OtherTest", nil, nil, false)
    assert result == "not ok 5 is lame (OtherTest)"
  end

  test "format_line with skip" do
    result = format_line(true, 5, "is unspecific", "ATest", :skip, nil, false)
    assert result == "ok 5 is unspecific (ATest) # SKIP"
  end

  test "format_line with todo and message" do
    result = format_line(true, 12, "double check", "ThatTest", :todo, "fix", false)

    assert result == "ok 12 double check (ThatTest) # TODO fix"
  end

  test "format_line with color" do
    result = format_line(true, 42, "life the universe and everything", "SecretTest", nil, nil, true)
    assert result == "\e[32mok\e[0m 42 \e[32mlife the universe and everything\e[0m (SecretTest)"
  end
end
