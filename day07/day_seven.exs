{time, _} =
  :timer.tc(fn ->
    part_one = fn index, positions ->
      positions
      |> Enum.map(&abs(&1 - index))
    end

    part_two = fn index, positions ->
      positions
      |> Enum.map(fn position ->
        Enum.sum(0..abs(position - index))
      end)
    end

    positions =
      "input.txt"
      |> File.stream!()
      |> Enum.take(1)
      |> Enum.at(0)
      |> String.trim()
      |> String.split(",", trim: true)
      |> Enum.map(fn value ->
        case Integer.parse(value) do
          {v, _} -> v
          _ -> -1
        end
      end)

    [part_one: part_one, part_two: part_two]
    |> Enum.each(fn {kind, part_fn} ->
      result =
        0..Enum.max(positions)
        |> Enum.map(fn index ->
          Task.async(fn ->
            part_fn.(index, positions) |> Enum.sum()
          end)
        end)
        |> Task.await_many()
        |> Enum.min()

      IO.puts("#{kind} => #{result}")
    end)
  end)

IO.puts("#{time / 1_000_000}s")
