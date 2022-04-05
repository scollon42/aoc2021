defmodule Day08.DigitReader do
  @digit_segement_map [
    {2, [1]},
    {3, [7]},
    {4, [4]},
    {5, [2, 3, 5]},
    {6, [0, 6, 9]},
    {7, [8]}
  ]

  defmodule Digits do
    @type t :: %__MODULE__{
            signals: list(String.t()),
            outputs: list(String.t())
          }

    @enforce_keys [:signals, :outputs]
    defstruct [:signals, :outputs]

    @spec build(list(String.t()), list(String.t())) :: t()
    def build(signals, outputs) do
      %__MODULE__{
        signals: signals,
        outputs: outputs
      }
    end
  end

  @spec get_lines(String.t()) :: list(String.t())
  def get_lines(input_path) do
    input_path
    |> File.stream!()
    |> Enum.map(&String.trim/1)
  end

  @spec get_digits(list(String.t())) :: list(Digits.t())
  def get_digits(lines) do
    lines
    |> Enum.map(fn line ->
      [signals, outputs] =
        line
        |> String.split("|", trim: true)
        |> Enum.map(&String.split(&1, " ", trim: true))
        |> Enum.take(2)

      Digits.build(signals, outputs)
    end)
  end

  @spec count_simple_outputs(list(Digits.t())) :: non_neg_integer()
  def count_simple_outputs(digits) do
    digits
    |> Enum.map(fn %Digits{outputs: outputs} ->
      outputs
      |> Enum.reduce(0, fn output, acc ->
        case find_segment(output) do
          {_segment_count, [_digit]} -> acc + 1
          _ -> acc
        end
      end)
    end)
    |> Enum.sum()
  end

  @spec decode_signals(Digits.t()) :: map()
  def decode_signals(%Digits{signals: signals}) do
    simple_digits =
      signals
      |> Enum.reduce(%{}, fn signal, acc ->
        case find_segment(signal) do
          {_segment_count, [value]} ->
            Map.put(acc, value, signal)

          _ ->
            acc
        end
      end)

    four_angle = deduce_four_angle(simple_digits)

    five_segment_digits = find_five_segment_digits(signals, simple_digits, four_angle)
    six_segment_digits = find_six_segment_digits(signals, simple_digits, four_angle)

    simple_digits
    |> Map.merge(five_segment_digits)
    |> Map.merge(six_segment_digits)
  end

  @spec decode_output(Digits.t(), map()) :: non_neg_integer()
  def decode_output(%Digits{outputs: outputs}, decoded_signals) do
    outputs
    |> Enum.map(fn output ->
      {digit, _} =
        Enum.find(decoded_signals, fn {_digit, decoded_signal} ->
          decoded_signal =
            decoded_signal
            |> String.codepoints()
            |> Enum.sort()

          output =
            output
            |> String.codepoints()
            |> Enum.sort()

          decoded_signal == output
        end)

      digit
    end)
    |> Integer.undigits()
  end

  defp find_five_segment_digits(signals, %{1 => one}, four_angle) do
    digits = Enum.filter(signals, &(String.length(&1) == 5))
    three = find_digit(digits, one)

    digits = Enum.reject(digits, &(&1 == three))

    five = find_digit(digits, four_angle)

    digits = Enum.reject(digits, &(&1 == five))

    [two] = digits

    %{
      3 => three,
      5 => five,
      2 => two
    }
  end

  defp find_six_segment_digits(signals, %{4 => four}, four_angle) do
    digits = Enum.filter(signals, &(String.length(&1) == 6))

    nine = find_digit(digits, four)

    digits = Enum.reject(digits, &(&1 == nine))

    six = find_digit(digits, four_angle)

    digits = Enum.reject(digits, &(&1 == six))

    [zero] = digits

    %{
      6 => six,
      9 => nine,
      0 => zero
    }
  end

  defp find_digit(digits, matching_segment) do
    Enum.find(digits, fn digit ->
      [] == String.codepoints(matching_segment) -- String.codepoints(digit)
    end)
  end

  defp deduce_four_angle(%{1 => one, 4 => four}) do
    chars_to_replace = String.codepoints(one)

    String.replace(four, chars_to_replace, "")
  end

  defp find_segment(entry) do
    segments = entry |> String.length()

    Enum.find(@digit_segement_map, &(elem(&1, 0) == segments))
  end
end
