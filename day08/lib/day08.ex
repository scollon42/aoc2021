defmodule Day08 do
  alias Day08.DigitReader

  def main(_) do
    result =
      "input.txt"
      |> DigitReader.get_lines()
      |> DigitReader.get_digits()
      |> DigitReader.count_simple_outputs()

    IO.puts("part_one => #{result}")

    result =
      "input.txt"
      |> DigitReader.get_lines()
      |> DigitReader.get_digits()
      |> Enum.map(fn digit ->
        decoded_signals = DigitReader.decode_signals(digit)

        digit
        |> DigitReader.decode_output(decoded_signals)
      end)
      |> Enum.sum()

    IO.puts("part_two => #{result}")
  end
end
