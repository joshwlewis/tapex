# Tapex

TAP (Test Anything Protocol) formatter for Elixir's ExUnit.

## Features

- TAP formatted output
- Streams to STDOUT
- Optionally outputs ANSI colors
- ExUnit style failure output
- ExUnit style final report
- Reports SKIP directive for skipped tests
- Reports TODO directive for `@tag :todo` or `@tag todo: "Make it pass"`
- Space padded descriptions for legibility

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `tapex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:tapex, "~> 0.1.0", only: :test}]
end
```

  2. Specify it as your fomatter in `test/test_helper.exs`:

```elixir
  ExUnit.configure formatters: [Tapex]
  ExUnit.start()
```

## Usage

![color](http://d.pr/i/a1Hl+)


```
$ mix test --no-color
TAP version 13
ok       1 test format_counts/1 displays passed failed and skipped (Elixir.Tapex.ReportTest)
ok       2 test format_counts displays colors when enabled (Elixir.Tapex.ReportTest)
ok       3 Elixir.Tapex.ReportTest
not ok   4 test format_plan (Elixir.Tapex.TapTest)
#       1) test format_plan (Tapex.TapTest)
#          test/tapex/tap_test.exs:6
#          Assertion with == failed
#          code: format_plan(1) == "1.1"
#          lhs:  "1..1"
#          rhs:  "1.1"
#          stacktrace:
#            test/tapex/tap_test.exs:8: (test)
ok       5 test format_header (Elixir.Tapex.TapTest)
ok       6 Elixir.Tapex.TapTest
ok       7 test format_line with todo and message (Elixir.Tapex.LineTest)
ok       8 test format_line with color (Elixir.Tapex.LineTest)
ok       9 test format_line for fail (Elixir.Tapex.LineTest)
ok      10 test format_line with skip (Elixir.Tapex.LineTest)
ok      11 test format_line for pass (Elixir.Tapex.LineTest) # SKIP This test is flappy
ok      12 Elixir.Tapex.LineTest
ok      13 test format_diagnostic for test without color (Elixir.Tapex.DiagnosticTest)
ok      14 test format_diagnostic for TestCase with color (Elixir.Tapex.DiagnosticTest) # TODO Make assertions less strict
ok      15 Elixir.Tapex.DiagnosticTest
ok      16 test :case_finished prints TAP line (Elixir.TapexTest)
ok      17 test :suite_finished prints a report (Elixir.TapexTest)
ok      18 test init returns config (Elixir.TapexTest)
ok      19 test :test_finished event prints TAP line (Elixir.TapexTest)
ok      20 Elixir.TapexTest
1..20

Finished in 0.1 seconds
20 tests, 18 passed, 1 failed, 1 skipped, 1 todo

Randomized with seed 484706
```

## A note on test counts

ExUnit may flag a TestCase as a failure. This usually happens when a `setup_all`
hook fails. Since we report a `TestCase` as pass or fail according to the TAP
specification, test cases are included in the final counts. This means you'll
see a higher count of tests once you switch from ExUnit's formatter, which
doesn't count test cases towards the total test count.
