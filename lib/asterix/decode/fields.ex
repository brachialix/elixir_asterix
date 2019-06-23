defmodule Asterix.Decode.Fields do
  use Bitwise

  def unsigned_number_field(data, nr_bytes, field_name, value_factor \\ 1)
      when is_list(data) and
           is_integer(nr_bytes) and nr_bytes > 0 and
           is_atom(field_name) and
           is_number(value_factor) do
    {
      Map.put(%{}, field_name, Asterix.Decode.octets_unsigned(data, nr_bytes) * value_factor),
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
        Asterix.Decode.octets_signed(data, nr_bytes) * value_factor
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
        round(Asterix.Decode.octets_unsigned(data, @len_time_of_day_field) * 1000 / 128),
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
    modes = Asterix.Decode.octets_unsigned(data, @len_mode_s_field)

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
