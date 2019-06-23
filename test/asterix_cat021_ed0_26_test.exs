defmodule Asterix.Decode.Cat021.Ed0_26Test do
  use ExUnit.Case
  require Logger
  doctest Asterix.Decode.Cat021.Ed0_26
  alias Asterix.Decode.Cat021.Ed0_26

  setup_all do
    Logger.configure(level: :info)
  end

  ###########################################################################################################
  # FIELD DECODING
  ###########################################################################################################

  describe "decoding: field 010" do
    setup do
      {:ok,
        test_data: [
          {[<<0>>, <<0>>], {%{SAC: 0, SIC: 0}, []}},
          {[<<1>>, <<1>>], {%{SAC: 1, SIC: 1}, []}},
          {[<<16>>, <<100>>], {%{SAC: 16, SIC: 100}, []}},
          {[<<255>>, <<255>>], {%{SAC: 255, SIC: 255}, []}},
          {[<<31>>, <<127>>, <<10>>], {%{SAC: 31, SIC: 127}, [<<10>>]}}
        ]}
    end

    test "010", %{test_data: test_data} do
      Enum.each(test_data, fn {data, expected_value} ->
        assert Ed0_26.field_decoding_functions()[:I010].(data) == expected_value
      end)
    end
  end

  ###########################################################################################################

  describe "decoding: field 020" do
    setup do
      {:ok,
        test_data: [
          {[<<0>>], {%{ECAT: 0}, []}},
          {[<<16>>, <<100>>], {%{ECAT: 16}, [<<100>>]}},
          {[<<255>>, <<127>>, <<10>>], {%{ECAT: 255}, [<<127>>, <<10>>]}}
        ]}
    end

    test "020", %{test_data: test_data} do
      Enum.each(test_data, fn {data, expected_value} ->
        assert Ed0_26.field_decoding_functions()[:I020].(data) == expected_value
      end)
    end
  end

  ###########################################################################################################

  describe "decoding: field 030" do
    setup do
      {:ok,
        test_data: [
          {[<<0>>], {%{TOD: ~T{00:00:00.000000}}, []}},
          {[<<0>>, <<0>>, <<0>>], {%{TOD: ~T{00:00:00.000000}}, []}},
          #   1/128 s
          {[<<0>>, <<0>>, <<1>>], {%{TOD: ~T{00:00:00.008000}}, []}},
          #  (1/128)*256 s
          {[<<0>>, <<1>>, <<0>>], {%{TOD: ~T{00:00:02.000000}}, []}},
          # ((1/128)*256)*256 s
          {[<<1>>, <<0>>, <<0>>], {%{TOD: ~T{00:08:32.000000}}, []}},
          # 12*60*60 s *128 (LSB: 1/128)
          {[<<0x54>>, <<0x60>>, <<0>>], {%{TOD: ~T{12:00:00.000000}}, []}},
          {[<<0xA8>>, <<0xBF>>, <<0x80>>], {%{TOD: ~T{23:59:59.000000}}, []}},
          {[<<0xA8>>, <<0xC0>>, <<0x00>>], {%{TOD: ~T{00:00:00.000000}}, []}},
          {[<<0xA8>>, <<0xC0>>, <<0x00>>, <<1>>], {%{TOD: ~T{00:00:00.000000}}, [<<1>>]}}
        ]}
    end

    test "030", %{test_data: test_data} do
      Enum.each(test_data, fn {data, expected_value} ->
        assert Ed0_26.field_decoding_functions()[:I030].(data) == expected_value
      end)
    end
  end

  ###########################################################################################################

  describe "decoding: field 032" do
    setup do
      {:ok,
        test_data: [
          {[<<0>>], {%{TOD_ACC: 0}, []}},
          # 1/256 s
          {[<<1>>], {%{TOD_ACC: 0.00390625}, []}},
          {[<<255>>, <<100>>], {%{TOD_ACC: 1 - 0.00390625}, [<<100>>]}}
        ]}
    end

    test "032", %{test_data: test_data} do
      Enum.each(test_data, fn {data, expected_value} ->
        assert Ed0_26.field_decoding_functions()[:I032].(data) == expected_value
      end)
    end
  end

  ###########################################################################################################

  describe "decoding: field 040" do
    setup do
      {:ok,
        test_data: [
          {[<<0>>, <<0>>, <<1>>],
            {%{
              TRD_DCR: 0,
              TRD_GBS: 0,
              TRD_SIM: 0,
              TRD_TST: 0,
              TRD_RAB: 0,
              TRD_SAA: 0,
              TRD_SPI: 0,
              TRD_ATP: 0,
              TRD_ARC: 0
            }, [<<1>>]}},
          {[<<0b10101010>>, <<0b00101111>>, <<2>>],
            {%{
              TRD_DCR: 1,
              TRD_GBS: 0,
              TRD_SIM: 1,
              TRD_TST: 0,
              TRD_RAB: 1,
              TRD_SAA: 0,
              TRD_SPI: 1,
              TRD_ATP: 1,
              TRD_ARC: 1
            }, [<<2>>]}},
          {[<<0b01010101>>, <<0b00000111>>, <<3>>],
            {%{
              TRD_DCR: 0,
              TRD_GBS: 1,
              TRD_SIM: 0,
              TRD_TST: 1,
              TRD_RAB: 0,
              TRD_SAA: 1,
              TRD_SPI: 0,
              TRD_ATP: 0,
              TRD_ARC: 0
            }, [<<3>>]}},
          {[<<255>>, <<255>>, <<4>>],
            {%{
              TRD_DCR: 1,
              TRD_GBS: 1,
              TRD_SIM: 1,
              TRD_TST: 1,
              TRD_RAB: 1,
              TRD_SAA: 1,
              TRD_SPI: 1,
              TRD_ATP: 7,
              TRD_ARC: 3
            }, [<<4>>]}}
        ]}
    end

    test "040", %{test_data: test_data} do
      Enum.each(test_data, fn {data, expected_value} ->
        assert Ed0_26.field_040(data) == expected_value
      end)
    end
  end

  ###########################################################################################################

  describe "decoding: field 146" do
    setup do
      {:ok,
        test_data: [
          {[<<0>>,          <<0>>,    <<0>>], {%{ALT_ISS_SAS: 0, ALT_ISS_SOURCE: 0, ALT_ISS_FT: 0}, [<<0>>]}},
          {[<<0b11100000>>, <<0x00>>, <<1>>], {%{ALT_ISS_SAS: 1, ALT_ISS_SOURCE: 3, ALT_ISS_FT: 0},        [<<1>>]}},
          {[<<0b11000000>>, <<0x01>>, <<2>>], {%{ALT_ISS_SAS: 1, ALT_ISS_SOURCE: 2, ALT_ISS_FT: 25},       [<<2>>]}},
          {[<<0b10110000>>, <<0x01>>, <<3>>], {%{ALT_ISS_SAS: 1, ALT_ISS_SOURCE: 1, ALT_ISS_FT: -25},      [<<3>>]}},
          {[<<0b10001111>>, <<0xff>>, <<4>>], {%{ALT_ISS_SAS: 1, ALT_ISS_SOURCE: 0, ALT_ISS_FT: 4095*25},  [<<4>>]}},
          {[<<0b10011111>>, <<0xff>>, <<5>>], {%{ALT_ISS_SAS: 1, ALT_ISS_SOURCE: 0, ALT_ISS_FT: -4095*25}, [<<5>>]}},
        ]}
    end

    test "146", %{test_data: test_data} do
      Enum.each(test_data, fn {data, expected_value} ->
        assert Ed0_26.field_decoding_functions()[:I146].(data) == expected_value
      end)
    end
  end

  ###########################################################################################################

  describe "decoding: field 148" do
    setup do
      {:ok,
        test_data: [
          {[<<0>>,          <<0>>,    <<0>>], {%{ALT_FSS_MV: 0, ALT_FSS_AH: 0, ALT_FSS_AM: 0, ALT_FSS_FT: 0},        [<<0>>]}},
          {[<<0b11100000>>, <<0x00>>, <<1>>], {%{ALT_FSS_MV: 1, ALT_FSS_AH: 1, ALT_FSS_AM: 1, ALT_FSS_FT: 0},        [<<1>>]}},
          {[<<0b11000000>>, <<0x01>>, <<2>>], {%{ALT_FSS_MV: 1, ALT_FSS_AH: 1, ALT_FSS_AM: 0, ALT_FSS_FT: 25},       [<<2>>]}},
          {[<<0b10110000>>, <<0x01>>, <<3>>], {%{ALT_FSS_MV: 1, ALT_FSS_AH: 0, ALT_FSS_AM: 1, ALT_FSS_FT: -25},      [<<3>>]}},
          {[<<0b10001111>>, <<0xff>>, <<4>>], {%{ALT_FSS_MV: 1, ALT_FSS_AH: 0, ALT_FSS_AM: 0, ALT_FSS_FT: 4095*25},  [<<4>>]}},
          {[<<0b00011111>>, <<0xff>>, <<5>>], {%{ALT_FSS_MV: 0, ALT_FSS_AH: 0, ALT_FSS_AM: 0, ALT_FSS_FT: -4095*25}, [<<5>>]}},
        ]}
    end

    test "148", %{test_data: test_data} do
      Enum.each(test_data, fn {data, expected_value} ->
        assert Ed0_26.field_decoding_functions()[:I148].(data) == expected_value
      end)
    end
  end

  ###########################################################################################################

  @lsb_150_kts :math.pow(2,-14)*3600
  @lsb_150_mach 0.001
  describe "decoding: field 150" do
    setup do
      {:ok,
        test_data: [
          {[<<0>>,          <<0>>,    <<0>>], {%{AIRSPEED_IM: 0, AIRSPEED_IAS_KTS: 0},                [<<0>>]}},
          {[<<0b00000000>>, <<0x00>>, <<1>>], {%{AIRSPEED_IM: 0, AIRSPEED_IAS_KTS: 0},                [<<1>>]}},
          {[<<0b00000000>>, <<0x01>>, <<2>>], {%{AIRSPEED_IM: 0, AIRSPEED_IAS_KTS: @lsb_150_kts},     [<<2>>]}},
          {[<<0b00000000>>, <<0x0A>>, <<3>>], {%{AIRSPEED_IM: 0, AIRSPEED_IAS_KTS: @lsb_150_kts*10},  [<<3>>]}},
          {[<<0b10000000>>, <<0x00>>, <<1>>], {%{AIRSPEED_IM: 1, AIRSPEED_MACH:    0},                [<<1>>]}},
          {[<<0b10000000>>, <<0x01>>, <<2>>], {%{AIRSPEED_IM: 1, AIRSPEED_MACH:    @lsb_150_mach},    [<<2>>]}},
          {[<<0b10000000>>, <<0x0A>>, <<3>>], {%{AIRSPEED_IM: 1, AIRSPEED_MACH:    @lsb_150_mach*10}, [<<3>>]}},
        ]}
    end

    test "150", %{test_data: test_data} do
      Enum.each(test_data, fn {data, expected_value} ->
        assert Ed0_26.field_decoding_functions()[:I150].(data) == expected_value
      end)
    end

  end

  ###########################################################################################################
  # RECORD DECODING
  ###########################################################################################################

  describe "decoding: record level" do

    test "decoding: cat 021 ed 0.26 without asterix header" do

      test_data = test_record_cat021_ed0_26_wo_header()
                  |> :binary.bin_to_list()
                  |> Enum.map(&<<&1>>)

      fields = test_data
               |> Asterix.Decode.decode_record(21)

      assert fields[:SAC] == 0
      assert fields[:SIC] == 18
      assert fields[:ECAT] == 5
      assert fields[:TOD] == ~T[09:02:34.781000]
             # assert fields[:TOD_ACC] == #032
      assert fields[:TRD_DCR] == 0
      assert fields[:TRD_GBS] == 1
      assert fields[:TRD_SIM] == 0
      assert fields[:TRD_TST] == 1
      assert fields[:TRD_RAB] == 0
      assert fields[:TRD_SAA] == 0
      assert fields[:TRD_SPI] == 0
      assert fields[:TRD_ATP] == 1
      assert fields[:TRD_ARC] == 2
      assert fields[:MODEA] == 1361
      assert fields[:MODEA_TEXT_OCTAL] == "2521"
      assert fields[:MODEA_V] == 0
      assert fields[:MODEA_G] == 0
      assert fields[:MODEA_L] == 1
      assert fields[:MODES] == 1_193_046
      assert fields[:MODES_TEXT_HEX] == "123456"
      assert fields[:FOM_AC] == 0
      assert fields[:FOM_MN] == 0
      assert fields[:FOM_DC] == 0
      assert fields[:FOM_PA] == 7
      # assert fields[:VELACC] == 0 #095
      # assert fields[:TRAJINT] == #110
      assert fields[:LAT] == 11.25
      assert fields[:LON] == 5.625
      # assert fields[:SIGAMP] == #131
      # assert fields[:GEOM_ALT] == #140
      # assert fields[:FL] == #145
      # assert fields[:SELALT_INT] == #146
      # assert fields[:SELALT_FIN] == #148
      # assert fields[:ASPD_CALC] == #150
      # assert fields[:ASPD_TRUE] == #151
      # assert fields[:HDG_MAG] == #152
      # assert fields[:] == #155
      # assert fields[:] == #157
      # assert fields[:] ==#160
      # assert fields[:] == #165
      assert fields[:TID] == "ABC12345"
      assert fields[:TSTAT] == 0
      assert fields[:LTI_DTI] == 0
      assert fields[:LTI_MDS] == 1
      assert fields[:LTI_UAT] == 0
      assert fields[:LTI_VDL] == 0
      assert fields[:LTI_OTR] == 0
      # assert fields[:] == #220
      # assert fields[:] == #230

      assert Map.size(fields) == 33
    end

    ###########################################################################################################

    test "decoding: cat 021 ed 0.26 with asterix header" do

      test_data = test_record_cat021_ed0_26_w_header()
                  |> :binary.bin_to_list()
                  |> Enum.map(&<<&1>>)

      {fields, _data} = test_data
                        |> Asterix.Decode.decode_block()

      assert Map.size(fields) == 33
    end

  end

  ###########################################################################################################
  # PERFORMANCE
  ###########################################################################################################

  describe "performance" do

    test "decode loop" do

      test_data = test_record_cat021_ed0_26_w_header()
                  |> :binary.bin_to_list()
                  |> Enum.map(&<<&1>>)

      start_dt = Time.utc_now()
      Enum.each(1..10000, fn _x -> test_data |> Asterix.Decode.decode_block() end)
      Logger.info("#{inspect(__ENV__.function)} took #{Time.diff(Time.utc_now(), start_dt, :millisecond)} ms}")
    end

  end

  ###########################################################################################################
  # TEST DATA
  ###########################################################################################################

  def test_record_cat021_ed0_26_wo_header do
    <<
      # fspec
      0xFB,
      0x81,
      0x13,
      0x84,
      # 010
      0x00,
      0x12,
      # 040
      0x50,
      0x30,
      # 030
      0x3F,
      0x95,
      0x64,
      # 130
      0x00,
      0x20,
      0x00,
      0x00,
      0x00,
      0x10,
      0x00,
      0x00,
      # 080
      0x12,
      0x34,
      0x56,
      # 090
      0x00,
      0x07,
      # 210
      0x08,
      # 170
      0x04,
      0x20,
      0xF1,
      0xCB,
      0x3D,
      0x35,
      # 200
      0x00,
      # 020
      0x05,
      # 070
      0x25,
      0x51
    >>
  end

  def test_record_cat021_ed0_26_w_header do
    <<
      0x15,
      # block length
      0x00,
      0x26
    >> <> test_record_cat021_ed0_26_wo_header()
  end

end
