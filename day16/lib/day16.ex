defmodule Day16 do
  use Bitwise

  defmodule Packet do
    @enforce_keys [:version, :type]
    defstruct [:version, :type, :value, subpackets: [], length: nil, length_type: -1]

    @literal_type 4
    @sum_type 0
    @product_type 1
    @minimum_type 2
    @maximum_type 3
    @gt_type 5
    @lt_type 6
    @eq_type 7

    @bits_length_type 0
    @count_length_type 1
    @header_size 6

    def new(bits) when length(bits) > @header_size do
      {packet, bits} = build(bits)

      decode(packet, bits)
    end

    def new(_), do: nil

    defp build(bits) do
      {{version, type}, bits} = get_header_and_updated_bits(bits)

      {%__MODULE__{
         version: version,
         type: type
       }, bits}
    end

    defp decode(%Packet{type: @literal_type} = packet, bits) do
      {data, bits} = get_data_and_updated_bits(bits)

      {%{packet | value: data}, bits}
    end

    defp decode(%Packet{} = packet, bits) do
      {length_type, bits} = get_length_type_and_updated_bits(packet.type, bits)
      {length, bits} = get_length_and_updated_bits(length_type, bits)

      {subpackets, bits} = get_subpackets_and_updated_bits(length_type, length, bits)

      {%{
         packet
         | length_type: length_type,
           length: length,
           subpackets: subpackets
       }, bits}
    end

    def get_value(%__MODULE__{type: @literal_type, value: value}), do: value

    def get_value(%__MODULE__{type: type, subpackets: subpackets}) do
      subpackets
      |> Enum.map(&get_value/1)
      |> apply_operation(type)
    end

    defp apply_operation(values, @sum_type), do: Enum.sum(values)
    defp apply_operation(values, @product_type), do: Enum.product(values)
    defp apply_operation(values, @maximum_type), do: Enum.max(values)
    defp apply_operation(values, @minimum_type), do: Enum.min(values)
    defp apply_operation([a, b], @gt_type), do: if(a > b, do: 1, else: 0)
    defp apply_operation([a, b], @lt_type), do: if(a < b, do: 1, else: 0)
    defp apply_operation([a, b], @eq_type), do: if(a == b, do: 1, else: 0)

    defp get_header_and_updated_bits(bits) do
      version = get_version(bits)
      type = get_type(bits)

      bits = Enum.drop(bits, @header_size)

      {{version, type}, bits}
    end

    defp get_data_and_updated_bits(bits) do
      {data, read_count} =
        bits
        |> Enum.chunk_every(5)
        |> Enum.reduce_while({0, 0}, fn
          [1 | bits], {acc, count} ->
            acc = acc <<< 4
            acc = acc + Integer.undigits(bits, 2)
            {:cont, {acc, count + 5}}

          [0 | bits], {acc, count} ->
            acc = acc <<< 4
            acc = acc + Integer.undigits(bits, 2)
            {:halt, {acc, count + 5}}
        end)

      {data, Enum.drop(bits, read_count)}
    end

    defp get_length_and_updated_bits(-1, bits), do: {nil, bits}

    defp get_length_and_updated_bits(0, bits) do
      length = Enum.take(bits, 15) |> Integer.undigits(2)

      bits = Enum.drop(bits, 15)

      {length, bits}
    end

    defp get_length_and_updated_bits(1, bits) do
      length = Enum.take(bits, 11) |> Integer.undigits(2)

      bits = Enum.drop(bits, 11)

      {length, bits}
    end

    defp get_length_type_and_updated_bits(@literal_type, bits), do: {-1, bits}

    defp get_length_type_and_updated_bits(_, bits) do
      [length_type | _] = bits
      {length_type, Enum.drop(bits, 1)}
    end

    defp get_subpackets_and_updated_bits(length_type, length, bits, subpackets \\ [])

    defp get_subpackets_and_updated_bits(_, length, bits, subpackets)
         when length <= 0,
         do: {subpackets, bits}

    defp get_subpackets_and_updated_bits(_, _length, [], subpackets),
      do: {subpackets, []}

    defp get_subpackets_and_updated_bits(length_type, length, bits, subpackets) do
      {subpacket, remaining_bits} = new(bits)

      updated_length =
        updated_length(length_type, length, Enum.count(bits) - Enum.count(remaining_bits))

      get_subpackets_and_updated_bits(
        length_type,
        updated_length,
        remaining_bits,
        subpackets ++ [subpacket]
      )
    end

    defp updated_length(@bits_length_type, length, read_bits_count), do: length - read_bits_count
    defp updated_length(@count_length_type, length, _), do: length - 1

    defp get_version(bits) do
      bits |> Enum.slice(0..2) |> Integer.undigits(2)
    end

    defp get_type(bits) do
      bits |> Enum.slice(3..5) |> Integer.undigits(2)
    end
  end

  def main([input_file]) do
    {packet, _} =
      input_file
      |> File.read!()
      |> get_bits()
      |> Packet.new()

    IO.puts("(part1) Summed version is #{sum_versions(packet)}")
    IO.puts("(part2) Packet value is #{Packet.get_value(packet)}")
  end

  def main(_), do: IO.puts("Usage : ./day16 input.txt")

  def sum_versions(packet, acc \\ 0)

  def sum_versions(%Packet{version: version, subpackets: []}, acc) do
    acc + version
  end

  def sum_versions(%Packet{version: version, subpackets: subpackets}, acc) do
    sub_versions = subpackets |> Enum.reduce(0, &sum_versions/2)

    acc + version + sub_versions
  end

  # @spec get_bits(String.t()) :: list(non_neg_integer())
  def get_bits(str) do
    str
    |> String.trim()
    |> String.codepoints()
    |> Enum.flat_map(fn hex ->
      {hex, _} = Integer.parse(hex, 16)

      digits = Integer.digits(hex, 2)

      case 4 - Enum.count(digits) do
        padding when padding > 0 ->
          (1..padding |> Enum.map(fn _ -> 0 end)) ++ digits

        _ ->
          digits
      end
    end)
  end
end
