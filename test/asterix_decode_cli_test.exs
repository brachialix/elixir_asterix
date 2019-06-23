defmodule Asterix.Decode.CliTest do
  use ExUnit.Case

  ##############################################################################

  test "cli: parse_args: fallback" do
    assert Asterix.Decode.Cli.parse_args([]) == :help
  end

  test "cli: parse_args: help" do
    assert Asterix.Decode.Cli.parse_args(["--help"]) == :help
    assert Asterix.Decode.Cli.parse_args(["-h"]) == :help
  end

  test "cli: parse_args: single string" do
    assert Asterix.Decode.Cli.parse_args(["filename"]) == %{ filename: "filename" }
  end

  test "cli: parse_args: multi string" do
    assert Asterix.Decode.Cli.parse_args(["filename", "too much"]) == :help
  end

  test "cli: parse_args: multi params" do
    assert Asterix.Decode.Cli.parse_args(["filename", 123]) == :help
  end

end
