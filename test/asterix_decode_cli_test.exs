defmodule Asterix.Decode.CliTest do
  use ExUnit.Case
  require Logger

  test "cli: fallback" do
    assert Asterix.Decode.Cli.parse_args([]) == :help
  end

  test "cli: help" do
    assert Asterix.Decode.Cli.parse_args(["--help"]) == :help
    assert Asterix.Decode.Cli.parse_args(["-h"]) == :help
  end

  test "cli: single string" do
    assert Asterix.Decode.Cli.parse_args(["filename"]) == %{ filename: "filename" }
  end

  test "cli: multi string" do
    assert Asterix.Decode.Cli.parse_args(["filename", "too much"]) == :help
  end

  test "cli: multi params" do
    assert Asterix.Decode.Cli.parse_args(["filename", 123]) == :help
  end

end
