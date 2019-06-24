defmodule Asterix.Decode.Cli do

  def main(argv) do
    run(argv)
  end

  def run() do
    run([])
  end

  def run(argv) do
    parse_args(argv)
    |> process
  end

  ##############################################################################

  def parse_args(argv) do
    OptionParser.parse(argv,
      switches: [ help: :boolean],
      aliases:  [ h:    :help])
    |> elem(1)
    |> parse_args_internal()
  end

  defp parse_args_internal([asterix_filename]) when is_binary(asterix_filename) do
    %{ filename: asterix_filename }
  end

  defp parse_args_internal(_) do
    :help
  end

  ##############################################################################

  def process(:help) do
    IO.puts("""
    Usage: <asterix filename>
    """)
    System.halt(0)
  end

  def process(%{filename: asterix_filename} = _args) do
    asterix_filename
    |> File.open!([:read, :binary])
    |> IO.binstream(1)
    |> Asterix.Decode.decode_blocks()
    |> IO.inspect(limit: :infinity)
  end

end