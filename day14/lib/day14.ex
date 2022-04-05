defmodule Day14 do
  def main(args) do
    case args do
      [filename, steps] ->
        {steps, _} = Integer.parse(steps)

        do_main(filename, steps)

      _ ->
        IO.puts("Usage ./day14 input.txt STEPS")
    end
  end

  defp do_main(filename, steps) do
    [start | rules] = lines(filename)

    start = String.codepoints(start)
    last_value = List.last(start) |> IO.inspect()
    rules = format_rules(rules)
    counter_map = build_map(start, rules) |> IO.inspect()

    polymer_parts =
      1..steps
      |> Enum.reduce(counter_map, fn _step, counter_map ->
        counter_map
        |> Enum.reduce(%{}, fn {<<a::size(8), b::size(8)>> = key, value}, acc ->
          insert = Map.get(rules, key)

          key1 = <<a>> <> insert
          key2 = insert <> <<b>>

          acc
          |> Map.put(key1, Map.get(acc, key1, 0) + value)
          |> Map.put(key2, Map.get(acc, key2, 0) + value)
        end)
        |> Enum.into(%{})
      end)
      |> IO.inspect()

    frequencies =
      polymer_parts
      |> Enum.reduce(%{}, fn {<<a::size(8)>> <> _rest, value}, acc ->
        Map.put(acc, <<a>>, Map.get(acc, <<a>>, 0) + value)
      end)
      |> IO.inspect()

    frequencies = Map.put(frequencies, last_value, Map.get(frequencies, last_value, 0) + 1)

    frequencies_values = Map.values(frequencies)

    min = Enum.min(frequencies_values)
    max = Enum.max(frequencies_values)

    IO.puts("For steps #{steps} => #{max - min}")
  end

  defp build_map(start_polymer, rules) do
    map =
      rules
      |> Map.map(fn {_key, _} ->
        0
      end)

    start_polymer
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.reduce(map, fn [a, b], acc ->
      key = a <> b

      Map.put(acc, key, Map.get(acc, key, 0) + 1)
    end)
  end

  defp format_rules(rules) do
    rules
    |> Enum.map(fn rule ->
      [pattern, insert] =
        rule
        |> String.split("->", trim: true)
        |> Enum.take(2)
        |> Enum.map(&String.trim/1)

      {pattern, insert}
    end)
    |> Map.new()
  end

  defp lines(filename) do
    filename
    |> File.stream!()
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 in ["", nil]))
  end
end
