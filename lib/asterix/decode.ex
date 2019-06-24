defmodule Asterix.Decode do
  require Logger
  use Bitwise
  alias Asterix.Decode.Cat021

  @doc """
     Decodes ASTERIX records from the given IO.Stream or given list of binaries
     until no more records can be decoded successfully.
  """
  def decode_blocks(data, field_list \\ []) do
    try do
      {fields, data} = data |> decode_block
      field_list = field_list ++ [fields]
      decode_blocks(data, field_list)
    rescue
      _ -> field_list
    end
  end

  @doc """
     Decodes ASTERIX records from the given IO.Stream.
  """
  def decode_block(data) when is_map(data) do
    {category, _} =
    data
    |> Enum.take(1)
    |> decode_category

    {block_length, _} =
    data
    |> Enum.take(2)
    |> decode_block_length

    asterix_record =
    data
    |> Enum.take(block_length - 3)

    fields = decode_record(asterix_record, category)
    
    {fields, data}
  end

  @doc """
     Decodes ASTERIX records from the given list of binaries.
  """
  def decode_block(data) when is_list(data) do
    {category, data} = decode_category(data)
    {block_length, data} = decode_block_length(data)
    asterix_record = data |> Enum.take(block_length - 3)
    fields = decode_record(asterix_record, category)
    {fields, data}
  end

  def decode_record(asterix_record, category) do
    case category do
      21 -> decode_record(asterix_record, Cat021.Ed0_26.uap(), Cat021.Ed0_26.field_decoding_functions())
      _ ->
        Logger.error("no ASTERIX decoder for CAT #{category}")
        %{}
    end
  end

  defp decode_record(asterix_record, uap, field_decoding_functions) when
       is_list(asterix_record) and
       is_list(uap) and
       is_map(field_decoding_functions)
  do

    {fspec, data} = decode_fspec(asterix_record, uap)

    {fields, _data} = List.foldl(fspec, {%{}, data}, fn field, acc ->
      {fields, data} = acc

      if Map.has_key?(field_decoding_functions, field) do
        {new_fields, data} = field_decoding_functions[field].(data)
        {Map.merge(fields, new_fields), data}
      else
        {fields, data}
      end
    end)

    fields
  end

  @category_octets 1
  defp decode_category(data) when is_list(data) do
    {octets_unsigned_int(data, @category_octets), Enum.drop(data, @category_octets)}
  end

  @block_length_octets 2
  defp decode_block_length(data) when is_list(data) do
    {octets_unsigned_int(data, @block_length_octets), Enum.drop(data, @block_length_octets)}
  end

  defp decode_fspec(data, uap) when is_list(data) and is_list(uap) do
    List.foldl(uap, {[], data}, fn uap_block, {fspec, data} ->
      {frns, req_frn} = uap_block
      cond do
        is_nil(req_frn) or req_frn in fspec ->
          {fspec ++ (data |> octets_unsigned_int(1) |> fspec_octet(frns)), Enum.drop(data, 1)}
        true ->
          {fspec, data}
      end
    end)
  end

  defp fspec_octet(octet, fspec_field_names) when
       is_integer(octet) and octet >= 0 and octet < 256 and
       is_list(fspec_field_names) do
    cond do
      Enum.count(fspec_field_names) == 8 ->
        {fspec_fields, _bit_nr} =
        List.foldl(fspec_field_names, {[], 7}, fn field_name, acc ->
          {fspec_fields, bit_nr} = acc

          case bit_to_bool(octet, bit_nr) do
            true ->
              case field_name do
                nil -> {fspec_fields, bit_nr - 1}
                field_name -> {fspec_fields ++ [field_name], bit_nr - 1}
              end

            false ->
              {fspec_fields, bit_nr - 1}
          end
        end)

        fspec_fields

      true ->
        []
    end

  end

  @doc """
  Returns false if the bit at location "bit_nr" is , true otherwise.
  The LSB has bit_nr == 0, the MSB has bit_nr == 7
  """
  def bit_to_bool(octet, bit_nr)
      when is_integer(octet) and octet >= 0 and octet < 256 and
           is_integer(bit_nr) and bit_nr >= 0 and bit_nr < 8 do
    (octet >>> bit_nr &&& 1) != 0
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

  ###########################################################################################################

end
