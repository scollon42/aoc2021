defmodule Day10 do
  alias Day10.{LineParser, LineCloser}

  @error_point_map %{
    ")" => 3,
    "]" => 57,
    "}" => 1197,
    ">" => 25137
  }

  @closing_point_map %{
    ")" => 1,
    "]" => 2,
    "}" => 3,
    ">" => 4
  }

  def main(args \\ []) do
    case args do
      [input_path] ->
        do_main(input_path)

      _ ->
        IO.puts("usage : ./day10 input.txt")
    end
  end

  defp do_main(input_path) do
    lines =
      input_path
      |> File.stream!()
      |> Enum.map(&String.trim/1)

    error_score =
      lines
      |> Enum.reduce(%{}, &find_errors/2)
      |> Enum.reduce(0, &compute_errors_score/2)

    IO.puts("Part on => #{error_score}")

    closing_scores =
      lines
      |> Enum.map(fn line ->
        closing = LineCloser.try_close(line)

        Enum.reduce(closing, 0, fn c, acc ->
          acc * 5 + Map.get(@closing_point_map, c)
        end)
      end)
      |> Enum.reject(&(&1 == 0))
      |> Enum.sort()

    middle_index =
      closing_scores
      |> Enum.count()
      |> Integer.floor_div(2)

    closing_winner_score = Enum.at(closing_scores, middle_index)

    IO.puts("Part two => #{closing_winner_score}")
  end

  defp find_errors(line, acc) do
    case LineParser.parse(line) do
      {:ok, _} ->
        acc

      {:error, char} ->
        Map.put(acc, char, Map.get(acc, char, 0) + 1)
    end
  end

  defp compute_errors_score({c, n}, acc) do
    acc + Map.get(@error_point_map, c) * n
  end
end
