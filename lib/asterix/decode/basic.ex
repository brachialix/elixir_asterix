defmodule Asterix.Decode.Basic do
  use Bitwise

  def octets(data, nr_octets) do
    data
    |> Enum.take(nr_octets)
    |> Enum.map(fn x -> :binary.decode_unsigned(x, :little) end)
  end

  def octets_unsigned_int(data, nr_octets) do
    nr_bits = nr_octets*8
    <<value::unsigned-integer-size(nr_bits)>> = octets(data, nr_octets)
                                                |> IO.iodata_to_binary
    value
  end

  def octets_signed_int(data, nr_octets) do
    nr_bits = nr_octets*8
    <<value::signed-integer-size(nr_bits)>> = octets(data, nr_octets)
                                              |> IO.iodata_to_binary
    value
  end

  def binary_to_trimmed_string(binary) do
    binary
    |> Enum.map(fn x ->
      cond do
        x < 32 -> <<x + 64>>
        x >= 32 -> x
      end
    end)
    |> String.Chars.to_string()
    |> String.trim()
  end

end