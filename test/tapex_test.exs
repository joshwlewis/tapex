defmodule TapexTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  doctest Tapex

  test "init returns config" do
    capture_io fn ->
      {:ok, config} = Tapex.init(colors: [enabled: false])
      send self(), config
    end


    receive do
      %{type_counter: type_counter,
        state_counter: state_counter,
        test_count: test_count} ->
          assert type_counter == %{}
          assert state_counter == %{}
          assert is_integer(test_count)
    end
  end

  test "test_finished event prints TAP line" do
    test = %ExUnit.Test{
      state: nil,
      tags: [],
      name: "he makes it so",
      case: "PicardTest"
    }

    config = %{
      colorize: false,
      type_counter: %{},
      status_counter: %{},
      test_count: 0
    }

    output = capture_io fn ->
      {:ok, _} = Tapex.handle_event({:test_finished, test}, config)
    end

    assert Regex.match?(~r/^ok/, output)
  end


  test ":case_finished prints TAP line" do
    case = %ExUnit.TestCase{
      state: :failed,
      name: "DataTest"
    }

    config = %{
      colorize: false,
      type_counter: %{},
      status_counter: %{},
      test_count: 0
    }

    output = capture_io fn ->
      {:ok, _} = Tapex.handle_event({:case_finished, case}, config)
    end

    assert Regex.match?(~r/^not ok/, output)
  end
end
