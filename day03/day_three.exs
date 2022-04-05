defmodule DayThree do
  def part_one(input) do
    frequencies = get_frequencies(input)

    epsilon = calculate_rate_for(:epsilon, frequencies)
    gamma = calculate_rate_for(:gamma, frequencies)

    epsilon * gamma
  end

  def part_two(input, size) do
    %{epsilon: epsilon, gamma: gamma} =
      0..size
      |> Enum.reduce(%{epsilon: input, gamma: input}, fn index, acc ->
        acc =
          [:epsilon, :gamma]
          |> Enum.reduce(acc, fn kind, acc ->
            list = acc[kind]
            frequency = get_frequency_at(list, index)

            common_bit = find_common_bit(kind, frequency)

            Map.put(acc, kind, Enum.filter(list, &(Enum.at(&1, index) == common_bit)))
          end)

        acc
      end)

    get_binary(epsilon) * get_binary(gamma)
  end

  def parse_file_stream_input(file_stream) do
    file_stream
    |> Enum.map(fn line ->
      line
      |> String.trim()
      |> String.codepoints()
    end)
  end

  defp get_frequencies(list) do
    list
    |> List.zip()
    |> Enum.map(fn tuple ->
      tuple
      |> Tuple.to_list()
      |> Enum.frequencies()
    end)
  end

  defp get_frequency_at(list, index) do
    list
    |> get_frequencies()
    |> Enum.at(index)
  end

  defp calculate_rate_for(kind, frequencies) do
    frequencies
    |> Enum.map(&find_common_bit(kind, &1))
    |> get_binary()
  end

  defp get_binary(list) do
    {bin, _} =
      list
      |> Enum.join()
      |> Integer.parse(2)

    bin
  end

  defp find_common_bit(:epsilon, bits) do
    case bits do
      %{"0" => x, "1" => x} ->
        "1"

      bits ->
        {bit, _} = Enum.max_by(bits, fn {_k, count} -> count end)
        bit
    end
  end

  defp find_common_bit(:gamma, bits) do
    case bits do
      %{"0" => x, "1" => x} ->
        "0"

      bits ->
        {bit, _} = Enum.min_by(bits, fn {_k, count} -> count end)
        bit
    end
  end
end

input =
  "input"
  |> File.stream!()
  |> DayThree.parse_file_stream_input()

line_size = (input |> hd |> Enum.count()) - 1

IO.puts("Result part 1 => #{DayThree.part_one(input)}")
IO.puts("Result part 2 => #{DayThree.part_two(input, line_size)}")
