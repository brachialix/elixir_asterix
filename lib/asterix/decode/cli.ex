defmodule Asterix.Decode.Cli do

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

  defp process(:help) do
    IO.puts("""
    Usage: <asterix filename>
    """)
    System.halt(0)
  end

  defp process(%{filename: asterix_filename} = _args) do
    asterix_filename
    |> File.open!([:read, :binary])
    |> IO.binstream(1)
    |> Asterix.Decode.decode_blocks()
  end

end