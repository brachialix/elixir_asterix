defmodule Asterix.Decode do
  use Bitwise
  require Logger
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

    {fields, _data} =
    List.foldl(fspec, {%{}, data}, fn field, acc ->
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
    {octets_summed(data, @category_octets), Enum.drop(data, @category_octets)}
  end

  @block_length_octets 2
  defp decode_block_length(data) when is_list(data) do
    {octets_summed(data, @block_length_octets), Enum.drop(data, @block_length_octets)}
  end

  defp decode_fspec(data, uap) when is_list(data) and is_list(uap) do
    List.foldl(uap, {[], data}, fn uap_block, {fspec, data} ->
      {frns, req_frn} = uap_block

      cond do
        is_nil(req_frn) or req_frn in fspec ->
          {fspec ++ (data |> octets_summed(1) |> fspec_octet(frns)), Enum.drop(data, 1)}

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

  def octets_summed(data, nr_octets) do
    octets(data, nr_octets)
    |> sum_octets
  end

  def octets_summed_signed(data, nr_octets) do
    octets(data, nr_octets)
    |> sum_octets
    |> (fn x -> two_complement(x, nr_octets) end).()
  end

  def two_complement(number, nr_octets)
      when is_integer(number) and number >= 0 and
           is_integer(nr_octets) and nr_octets > 0 and nr_octets <= 4 do
    case number >>> (nr_octets * 8 - 1) do
      0 -> number
      1 -> ~~~number + 1
    end
  end

  def sum_octets(octets) do
    {sum, _factor} =
    List.foldr(octets, {0, 1}, fn octet, acc ->
      {sum, factor} = acc
      {sum + octet * factor, factor * 256}
    end)

    sum
  end

  ###########################################################################################################

  defmodule Fields do
    def unsigned_number_field(data, nr_bytes, field_name, value_factor \\ 1)
        when is_list(data) and
             is_integer(nr_bytes) and nr_bytes > 0 and
             is_atom(field_name) and
             is_number(value_factor) do
      {
        Map.put(%{}, field_name, Asterix.Decode.octets_summed(data, nr_bytes) * value_factor),
        Enum.drop(data, nr_bytes)
      }
    end

    def signed_number_field(data, nr_bytes, field_name, value_factor \\ 1)
        when is_list(data) and
             is_integer(nr_bytes) and nr_bytes > 0 and
             is_atom(field_name) and
             is_number(value_factor) do
      {
        Map.put(
          %{},
          field_name,
          Asterix.Decode.octets_summed_signed(data, nr_bytes) * value_factor
        ),
        Enum.drop(data, nr_bytes)
      }
    end

    def sac_sic_field(data) when is_list(data) do
      {result1, data} = unsigned_number_field(data, 1, :SAC)
      {result2, data} = unsigned_number_field(data, 1, :SIC)
      {Map.merge(result1, result2), data}
    end

    @len_time_of_day_field 3
    def time_of_day_field(data) when is_list(data) do
      {%{
        TOD:
        Time.add(
          ~T[00:00:00],
          round(Asterix.Decode.octets_summed(data, @len_time_of_day_field) * 1000 / 128),
          :millisecond
        )
      }, Enum.drop(data, @len_time_of_day_field)}
    end

    @len_mode_a_field 2
    def mode_a_field(data) when is_list(data) do
      <<v::1, g::1, l::1, _::1, a4::3, a3::3, a2::3, a1::3>> =
      Asterix.Decode.octets(data, @len_mode_a_field)
      |> IO.iodata_to_binary()

      modea = Integer.undigits([a4, a3, a2, a1], 8)

      {%{
        MODEA: modea,
        MODEA_TEXT_OCTAL: Integer.to_string(modea, 8),
        MODEA_V: v,
        MODEA_G: g,
        MODEA_L: l
      }, Enum.drop(data, @len_mode_a_field)}
    end

    @len_mode_s_field 3
    def mode_s_field(data) when is_list(data) do
      modes = Asterix.Decode.octets_summed(data, @len_mode_s_field)

      {%{MODES: modes, MODES_TEXT_HEX: Integer.to_string(modes, 16)},
        Enum.drop(data, @len_mode_s_field)}
    end

    @latlon_factor 180 / (1 <<< 25)
    def lat_lon_field(data) when is_list(data) do
      {result1, data} = Asterix.Decode.Fields.signed_number_field(data, 4, :LAT, @latlon_factor)
      {result2, data} = Asterix.Decode.Fields.signed_number_field(data, 4, :LON, @latlon_factor)
      {Map.merge(result1, result2), data}
    end

    @len_target_id_field 6
    def target_id_field(data) when is_list(data) do
      <<c1::6, c2::6, c3::6, c4::6, c5::6, c6::6, c7::6, c8::6>> =
      Asterix.Decode.octets(data, @len_target_id_field) |> IO.iodata_to_binary()

      {%{TID: [c1, c2, c3, c4, c5, c6, c7, c8] |> Asterix.Decode.binary_to_trimmed_string()},
        Enum.drop(data, @len_target_id_field)}
    end
  end
end
