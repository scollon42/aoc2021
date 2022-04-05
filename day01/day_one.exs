defmodule DayOne do
  @moduledoc false

  @spec part_one(list(integer())) :: non_neg_integer()
  def part_one(inputs) do
    {_last, count} =
      inputs
      |> Enum.reduce({}, fn input, acc ->
        case acc do
          {} ->
            {input, 0}

          {previous, count} ->
            if(previous < input, do: {input, count + 1}, else: {input, count})
        end
      end)

    count
  end

  @spec part_two(list(integer())) :: non_neg_integer()
  def part_two(inputs) do
    inputs
    |> Stream.chunk_every(3, 1)
    |> Enum.map(&Enum.sum/1)
    |> part_one()
  end
end

IO.puts("Start")

inputs =
  "inputs"
  |> File.stream!()
  |> Enum.map(&(&1 |> String.trim() |> String.to_integer()))

"Day 1 - part 1 => #{DayOne.part_one(inputs)}" |> IO.puts()
"Day 1 - part 2 => #{DayOne.part_two(inputs)}" |> IO.puts()

IO.puts("End")
