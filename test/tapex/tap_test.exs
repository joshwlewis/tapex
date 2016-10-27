defmodule Tapex.TapTest do
  use ExUnit.Case, async: true

  import Tapex.Tap

  test "format_plan" do
    assert format_plan(0) == "1..0"
    assert format_plan(1) == "1..1"
    assert format_plan(101) == "1..101"
  end

  test "format_header" do
    assert format_header() == "TAP version 13"
  end
end
