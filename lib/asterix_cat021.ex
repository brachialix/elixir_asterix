defmodule Asterix.Decode.Cat021 do
  use Bitwise

  defmodule Ed0_26 do
    def field_decoding_functions do
      %{
        :I010 => &Asterix.Decode.Fields.sac_sic_field/1,
        :I020 => &Asterix.Decode.Fields.unsigned_number_field(&1, 1, :ECAT),
        :I030 => &Asterix.Decode.Fields.time_of_day_field/1,
        :I032 => &Asterix.Decode.Fields.unsigned_number_field(&1, 1, :TOD_ACC, 1 / 256),
        :I040 => &__MODULE__.field_040/1,
        :I070 => &Asterix.Decode.Fields.mode_a_field/1,
        :I080 => &Asterix.Decode.Fields.mode_s_field/1,
        :I090 => &__MODULE__.field_090/1,
        :I095 => &Asterix.Decode.Fields.unsigned_number_field(&1, 1, :VELACC),
      # TODO 110
        :I130 => &Asterix.Decode.Fields.lat_lon_field/1,
        :I131 => &Asterix.Decode.Fields.unsigned_number_field(&1, 1, :SIGAMP),
        :I140 => &Asterix.Decode.Fields.signed_number_field(&1, 2, :GEOM_ALT, 6.25),
        :I145 => &Asterix.Decode.Fields.signed_number_field(&1, 2, :FL, 1 / 4),
      # TODO 146
      # TODO 148
      # TODO 150
        :I151 => &Asterix.Decode.Fields.unsigned_number_field(&1, 1, :TAS),
        :I152 => &Asterix.Decode.Fields.unsigned_number_field(&1, 1, :HDG_MAG, 360 / (1 <<< 16)),
        :I155 => &Asterix.Decode.Fields.signed_number_field(&1, 2, :BVR_FPM, 6.25),
        :I157 => &Asterix.Decode.Fields.signed_number_field(&1, 2, :GVR_FPM, 6.25),
        :I160 => &__MODULE__.field_160/1,
      # TODO 165
        :I170 => &Asterix.Decode.Fields.target_id_field/1,
        :I200 => &Asterix.Decode.Fields.unsigned_number_field(&1, 1, :TSTAT),
        :I210 => &__MODULE__.field_210/1,
      # TODO 220
        :I230 => &Asterix.Decode.Fields.signed_number_field(&1, 2, :ROLLANG, 0.01)
      }
    end

    def full_fspec do
      [
        {[:I010, :I040, :I030, :I130, :I080, :I140, :I090, :fx1],  nil},
        {[:I210, :I230, :I145, :I150, :I151, :I152, :I155, :fx2], :fx1},
        {[:I157, :I160, :I165, :I170, :I095, :I032, :I200, :fx3], :fx2},
        {[:I020, :I220, :I146, :I148, :I110, :I070, :I131, :fx4], :fx3},
        {[nil,   nil,   nil,   nil,   nil,   :RE,   :SP,   nil],  :fx4}
      ]
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

    @len_160_half 2
    def field_160(data) when is_list(data) do
      {%{
        GV_SPEED_KTS:
        Asterix.Decode.octets_summed_signed(data, @len_160_half) / (1 <<< 14) * 3600,
        GV_TRACKANGLE:
        Asterix.Decode.octets_summed(Enum.drop(data, @len_160_half), @len_160_half) /
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
end
