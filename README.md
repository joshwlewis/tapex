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

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `tapex` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:tapex, "~> 0.1.0"}]
    end
    ```

  2. Specify it as your fomatter in `test/test_helper.exs`:

    ```elixir
      ExUnit.configure formatters: [Tapex]
      ExUnit.start()
    ```
