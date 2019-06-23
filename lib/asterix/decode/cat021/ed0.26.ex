defmodule Asterix.Decode.Cat021.Ed0_26 do
  use Bitwise
  alias Asterix.Decode.Fields

  def uap do
    [
      {[:I010, :I040, :I030, :I130, :I080, :I140, :I090, :fx1],  nil},
      {[:I210, :I230, :I145, :I150, :I151, :I152, :I155, :fx2], :fx1},
      {[:I157, :I160, :I165, :I170, :I095, :I032, :I200, :fx3], :fx2},
      {[:I020, :I220, :I146, :I148, :I110, :I070, :I131, :fx4], :fx3},
      {[nil,   nil,   nil,   nil,   nil,   :RE,   :SP,   nil],  :fx4}
    ]
  end

  def field_decoding_functions do
    %{
      :I010 => &Fields.sac_sic_field/1,
      :I020 => &Fields.unsigned_number_field(&1, 1, :ECAT),
      :I030 => &Fields.time_of_day_field/1,
      :I032 => &Fields.unsigned_number_field(&1, 1, :TOD_ACC, 1 / 256),
      :I040 => &__MODULE__.field_040/1,
      :I070 => &Fields.mode_a_field/1,
      :I080 => &Fields.mode_s_field/1,
      :I090 => &__MODULE__.field_090/1,
      :I095 => &Fields.unsigned_number_field(&1, 1, :VELACC),
      :I110 => nil, # TODO 110
      :I130 => &Fields.lat_lon_field/1,
      :I131 => &Fields.unsigned_number_field(&1, 1, :SIGAMP),
      :I140 => &Fields.signed_number_field(&1,   2, :GEOM_ALT, 6.25),
      :I145 => &Fields.signed_number_field(&1,   2, :FL,       1 / 4),
      :I146 => &__MODULE__.field_146/1,
      :I148 => &__MODULE__.field_148/1,
      :I150 => &__MODULE__.field_150/1,
      :I151 => &Fields.unsigned_number_field(&1, 1, :TAS),
      :I152 => &Fields.unsigned_number_field(&1, 1, :HDG_MAG, 360 / (1 <<< 16)),
      :I155 => &Fields.signed_number_field(&1,   2, :BVR_FPM, 6.25),
      :I157 => &Fields.signed_number_field(&1,   2, :GVR_FPM, 6.25),
      :I160 => &__MODULE__.field_160/1,
      :I165 => nil, # TODO 165
      :I170 => &Fields.target_id_field/1,
      :I200 => &Fields.unsigned_number_field(&1, 1, :TSTAT),
      :I210 => &__MODULE__.field_210/1,
      :I220 => nil, # TODO 220
      :I230 => &Fields.signed_number_field(&1,   2, :ROLLANGLE, 0.01),
      # TODO RE
      # TODO SP
    }
  end

  @len_040 2
  def field_040(data) when is_list(data) do
    [<<dcr::1, gbs::1, sim::1, tst::1, rab::1, saa::1, spi::1, _::1>>, <<atp::3, arc::2, _::3>>] =
    Enum.take(data, @len_040)

    {%{
      TRD_DCR: dcr,
      TRD_GBS: gbs,
      TRD_SIM: sim,
      TRD_TST: tst,
      TRD_RAB: rab,
      TRD_SAA: saa,
      TRD_SPI: spi,
      TRD_ATP: atp,
      TRD_ARC: arc
    }, Enum.drop(data, @len_040)}
  end

  @len_090 2
  def field_090(data) when is_list(data) do
    [<<ac::2, mn::2, dc::2, _::2>>, <<_::4, pa::4>>] = Enum.take(data, @len_090)
    {%{FOM_PA: pa, FOM_DC: dc, FOM_MN: mn, FOM_AC: ac}, Enum.drop(data, @len_090)}
  end

  @len_146 2
  def field_146(data) when is_list(data) do
    <<sas::size(1), source::size(2), alt::signed-integer-size(13)>> = Enum.take(data, @len_146)
                                                                      |> IO.iodata_to_binary
    {%{ALT_ISS_SAS: sas,
      ALT_ISS_SOURCE: source,
      ALT_ISS_FT:  alt*25},
      Enum.drop(data, @len_146)}
  end

  @len_148 2
  def field_148(data) when is_list(data) do
    <<mv::1, ah::1, am::1, alt::signed-integer-size(13)>> = Enum.take(data, @len_148)
                                                            |> IO.iodata_to_binary
    {%{ALT_FSS_MV: mv,
      ALT_FSS_AH: ah,
      ALT_FSS_AM: am,
      ALT_FSS_FT: alt*25},
      Enum.drop(data, @len_148)}
  end

  @len_150 2
  def field_150(data) when is_list(data) do
    [<<im::1, spd_higher::7>>, <<spd_lower::8>>] = Enum.take(data, @len_150)

    case im do
      0 ->
        {%{AIRSPEED_IM: im,
          AIRSPEED_IAS_KTS: ((spd_higher <<< 8)+spd_lower) / (1 <<< 14) * 3600},
          Enum.drop(data, @len_150)}
      1 ->
        {%{AIRSPEED_IM: im,
          AIRSPEED_MACH: ((spd_higher <<< 8)+spd_lower) / 1000},
          Enum.drop(data, @len_150)}
    end
  end

  @len_160_half 2
  def field_160(data) when is_list(data) do
    {%{
      GV_SPEED_KTS:
      Asterix.Decode.octets_signed(data, @len_160_half) / (1 <<< 14) * 3600,
      GV_TRACKANGLE:
      Asterix.Decode.octets_unsigned(Enum.drop(data, @len_160_half), @len_160_half) /
      (1 <<< 16) * 360
    }, Enum.drop(data, @len_160_half * 2)}
  end

  @len_210 1
  def field_210(data) when is_list(data) do
    [<<_::3, dti::1, mds::1, uat::1, vdl::1, otr::1>>] = Enum.take(data, @len_210)

    {%{LTI_OTR: otr, LTI_VDL: vdl, LTI_UAT: uat, LTI_MDS: mds, LTI_DTI: dti},
      Enum.drop(data, @len_210)}
  end

end
