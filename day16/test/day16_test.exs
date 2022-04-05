defmodule Day16Test do
  use ExUnit.Case

  describe "get_bits/1" do
    test "with 0 hex string returns list of bits" do
      assert [0, 0, 0, 0] = Day16.get_bits("0")
    end

    test "with 1 hex string returns list of bits" do
      assert [0, 0, 0, 1] = Day16.get_bits("1")
    end

    test "with F hex string returns list of bits" do
      assert [1, 1, 1, 1] = Day16.get_bits("F")
    end

    test "with D2FE28 hex string returns list of bits" do
      bits = [1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0]

      assert ^bits = Day16.get_bits("D2FE28")
    end
  end

  describe "Packet.new/1" do
    test "with literal type packet representing 2021" do
      bits = [1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0]

      assert {%Day16.Packet{} = packet, remaining_bits} = Day16.Packet.new(bits)

      assert packet.type == 4
      assert packet.version == 6
      assert packet.value == 2021
      assert length(remaining_bits) == 3
    end

    test "with literal type packet representing 10" do
      bits = [1, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0]
      assert {%Day16.Packet{} = packet, remaining_bits} = Day16.Packet.new(bits)

      assert packet.type == 4
      assert packet.version == 6
      assert packet.value == 10
      assert length(remaining_bits) == 0
    end

    test "with literal type packet representing 20" do
      bits = [0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0]
      assert {%Day16.Packet{} = packet, remaining_bits} = Day16.Packet.new(bits)

      assert packet.type == 4
      assert packet.version == 2
      assert packet.value == 20
      assert length(remaining_bits) == 0
    end

    test "with operator and length type 0" do
      bits = Day16.get_bits("38006F45291200")

      assert {%Day16.Packet{} = packet, _remaining_bits} = Day16.Packet.new(bits)

      assert packet.type == 6
      assert packet.version == 1
      assert packet.length_type == 0
      assert packet.length == 27
      assert packet.subpackets |> length() == 2
    end

    test "with operator and length type 1" do
      bits = Day16.get_bits("EE00D40C823060")

      assert {%Day16.Packet{} = packet, _remaining_bits} = Day16.Packet.new(bits)

      assert packet.type == 3
      assert packet.version == 7
      assert packet.length_type == 1
      assert packet.length == 3
      assert packet.subpackets |> length() == 3
    end

    test "with operator and nested subpackets" do
      bits = Day16.get_bits("8A004A801A8002F478")

      assert {%Day16.Packet{} = packet, _remaining_bits} = Day16.Packet.new(bits)

      assert packet.type == 2
      assert packet.version == 4
      assert packet.length_type == 1
      assert packet.length == 1
      assert packet.subpackets |> length() == 1

      [subpacket1] = packet.subpackets

      assert subpacket1.type == 2
      assert subpacket1.version == 1
      assert subpacket1.length_type == 1
      assert subpacket1.length == 1

      [subpacket2] = subpacket1.subpackets
      assert subpacket2.type == 2
      assert subpacket2.version == 5
      assert subpacket2.length_type == 0
      assert subpacket2.length == 11

      [literal_packet] = subpacket2.subpackets
      assert literal_packet.type == 4
      assert literal_packet.version == 6
      assert literal_packet.value == 15
    end
  end

  describe "sum_versions/2" do
    test "with versions sumed to 16" do
      bits = Day16.get_bits("8A004A801A8002F478")

      assert {%Day16.Packet{} = packet, _remaining_bits} = Day16.Packet.new(bits)

      assert Day16.sum_versions(packet) == 16
    end

    @tag debug: true
    test "with versions sumed to 12" do
      bits = Day16.get_bits("620080001611562C8802118E34")

      assert {%Day16.Packet{} = packet, _remaining_bits} = Day16.Packet.new(bits)

      assert Day16.sum_versions(packet) == 12
    end

    test "with versions sumed to 23" do
      bits = Day16.get_bits("C0015000016115A2E0802F182340")

      assert {%Day16.Packet{} = packet, _remaining_bits} = Day16.Packet.new(bits)

      assert Day16.sum_versions(packet) == 23
    end

    test "with versions sumed to 31" do
      bits = Day16.get_bits("A0016C880162017C3686B18A3D4780")

      assert {%Day16.Packet{} = packet, _remaining_bits} = Day16.Packet.new(bits)

      assert Day16.sum_versions(packet) == 31
    end
  end

  describe "Packet.get_value/1" do
    test "with literal packet" do
      bits = [1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0]

      assert {%Day16.Packet{} = packet, _remaining_bits} = Day16.Packet.new(bits)

      assert Day16.Packet.get_value(packet) == 2021
    end

    test "with sum operator packet" do
      bits = Day16.get_bits("C200B40A82")

      assert {%Day16.Packet{} = packet, _remaining_bits} = Day16.Packet.new(bits)

      assert Day16.Packet.get_value(packet) == 3
    end

    test "with product operator packet" do
      bits = Day16.get_bits("04005AC33890")

      assert {%Day16.Packet{} = packet, _remaining_bits} = Day16.Packet.new(bits)

      assert Day16.Packet.get_value(packet) == 54
    end

    test "with min operator packet" do
      bits = Day16.get_bits("880086C3E88112")

      assert {%Day16.Packet{} = packet, _remaining_bits} = Day16.Packet.new(bits)

      assert Day16.Packet.get_value(packet) == 7
    end

    test "with max operator packet" do
      bits = Day16.get_bits("CE00C43D881120")

      assert {%Day16.Packet{} = packet, _remaining_bits} = Day16.Packet.new(bits)

      assert Day16.Packet.get_value(packet) == 9
    end

    test "with less than operator packet" do
      bits = Day16.get_bits("D8005AC2A8F0")

      assert {%Day16.Packet{} = packet, _remaining_bits} = Day16.Packet.new(bits)

      assert Day16.Packet.get_value(packet) == 1
    end

    test "with greater than operator packet" do
      bits = Day16.get_bits("F600BC2D8F")

      assert {%Day16.Packet{} = packet, _remaining_bits} = Day16.Packet.new(bits)

      assert Day16.Packet.get_value(packet) == 0
    end

    test "with eq  operator packet" do
      bits = Day16.get_bits("9C005AC2F8F0")

      assert {%Day16.Packet{} = packet, _remaining_bits} = Day16.Packet.new(bits)

      assert Day16.Packet.get_value(packet) == 0
    end

    test "with nested operator packets" do
      bits = Day16.get_bits("9C0141080250320F1802104A08")

      assert {%Day16.Packet{} = packet, _remaining_bits} = Day16.Packet.new(bits)

      assert Day16.Packet.get_value(packet) == 1
    end
  end
end
