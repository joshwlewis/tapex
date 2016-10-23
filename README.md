# Tapex

TAP (Test Anything Protocol) formatter for Elixir's ExUnit

*Status*: WIP

## Features

- Streaming output
- TAP plan provided before test runs
- TAP13 diagnostics
- Support for TAP todos via `@tag :todo` or `@tag todo: "This test
  occasionally fails, plz fix."`
- ExUnit style final report

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `tapex` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:tapex, "~> 0.1.0"}]
    end
    ```

  2. Ensure `tapex` is started before your application:

    ```elixir
    def application do
      [applications: [:tapex]]
    end
    ```

  3. Specify it as your fomatter in `test/test_helper.exs`:

    ```elixir
      ExUnit.configure formatters: [Tapex]
      ExUnit.start()
    ```

