defmodule Asterix.Decode.FieldsTest do
  use ExUnit.Case
  doctest Asterix.Decode.Fields
  alias Asterix.Decode.Fields

  ###########################################################################################################

  describe "decoding: unsigned_number_field : 1 octet, factor 1" do
    setup do
      {:ok,
        test_data: [
          {[<<255>>],                 {%{testfield: 255},   []}},
          {[<<0>>, <<0>>],            {%{testfield: 0},     [<<0>>]}},
          {[<<16>>, <<100>>],         {%{testfield: 16},    [<<100>>]}},
          {[<<31>>, <<127>>, <<10>>], {%{testfield: 31},    [<<127>>, <<10>>]}}
        ]}
    end

    test "", %{test_data: test_data} do
      Enum.each(test_data, fn {data, expected_value} ->
        assert Fields.unsigned_number_field(data, 1, :testfield, 1)  == expected_value
      end)
    end
  end

  describe "decoding: unsigned_number_field : 1 octet, factor 3" do
    setup do
      {:ok,
        test_data: [
          {[<<255>>],                 {%{testfield: 765},   []}},
          {[<<0>>, <<0>>],            {%{testfield: 0},     [<<0>>]}},
          {[<<16>>, <<100>>],         {%{testfield: 48},    [<<100>>]}},
          {[<<31>>, <<127>>, <<10>>], {%{testfield: 93},    [<<127>>, <<10>>]}}
        ]}
    end

    test "", %{test_data: test_data} do
      Enum.each(test_data, fn {data, expected_value} ->
        assert Fields.unsigned_number_field(data, 1, :testfield, 3)  == expected_value
      end)
    end
  end

  describe "decoding: unsigned_number_field : 2 octets, factor 1" do
    setup do
      {:ok,
        test_data: [
          {[<<0>>, <<0>>],            {%{testfield: 0},     []}},
          {[<<1>>, <<1>>],            {%{testfield: 257},   []}},
          {[<<0>>, <<100>>],          {%{testfield: 100},   []}},
          {[<<10>>, <<0>>, <<10>>],   {%{testfield: 2560},  [<<10>>]}}
        ]}
    end

    test "", %{test_data: test_data} do
      Enum.each(test_data, fn {data, expected_value} ->
        assert Fields.unsigned_number_field(data, 2, :testfield, 1)  == expected_value
      end)
    end
  end

  ###########################################################################################################
  ###########################################################################################################

  describe "decoding: signed_number_field : 1 octet, factor 1" do
    setup do
      {:ok,
        test_data: [
          {[<<128>>],                 {%{testfield: -128},  []}},
          {[<<0>>, <<0>>],            {%{testfield: 0},     [<<0>>]}},
          {[<<255>>, <<255>>],        {%{testfield: -1},    [<<255>>]}},
          {[<<31>>, <<127>>, <<10>>], {%{testfield: 31},    [<<127>>, <<10>>]}}
        ]}
    end

    test "", %{test_data: test_data} do
      Enum.each(test_data, fn {data, expected_value} ->
        assert Fields.signed_number_field(data, 1, :testfield, 1)  == expected_value
      end)
    end
  end

  describe "decoding: signed_number_field : 1 octet, factor 3" do
    setup do
      {:ok,
        test_data: [
          {[<<128>>],                 {%{testfield: -384},  []}},
          {[<<0>>, <<0>>],            {%{testfield: 0},     [<<0>>]}},
          {[<<255>>, <<255>>],        {%{testfield: -3},    [<<255>>]}},
          {[<<31>>, <<127>>, <<10>>], {%{testfield: 93},    [<<127>>, <<10>>]}}
        ]}
    end

    test "", %{test_data: test_data} do
      Enum.each(test_data, fn {data, expected_value} ->
        assert Fields.signed_number_field(data, 1, :testfield, 3)  == expected_value
      end)
    end
  end

  describe "decoding: signed_number_field : 2 octets, factor 1" do
    setup do
      {:ok,
        test_data: [
          {[<<128>>, <<0>>],          {%{testfield: -32768},[]}},
          {[<<1>>, <<1>>],            {%{testfield: 257},   []}},
          {[<<0>>, <<100>>],          {%{testfield: 100},   []}},
          {[<<10>>, <<0>>, <<10>>],   {%{testfield: 2560},  [<<10>>]}}
        ]}
    end

    test "", %{test_data: test_data} do
      Enum.each(test_data, fn {data, expected_value} ->
        assert Fields.signed_number_field(data, 2, :testfield, 1)  == expected_value
      end)
    end
  end

end
