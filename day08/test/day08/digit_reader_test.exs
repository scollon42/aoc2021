defmodule Day08.DigitReaderTest do
  use ExUnit.Case

  alias Day08.DigitReader

  describe "get_digits/1" do
    test "with simple input" do
      lines = [
        "acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf"
      ]

      digit_list = DigitReader.get_digits(lines)

      assert digit_list |> length() == 1
      assert [%DigitReader.Digits{signals: signals, outputs: outputs}] = digit_list
      assert signals |> length() == 10
      assert outputs |> length() == 4
    end

    test "with more lines" do
      lines = [
        "be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe",
        "edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc",
        "fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg"
      ]

      digit_list = DigitReader.get_digits(lines)

      assert digit_list |> length() == 3

      Enum.each(digit_list, fn digit ->
        assert %DigitReader.Digits{signals: signals, outputs: outputs} = digit
        assert signals |> length() == 10
        assert outputs |> length() == 4
      end)
    end
  end

  describe "count_simple_outputs/1" do
    test "with simple input" do
      digits = [
        DigitReader.Digits.build(
          ~w(be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb)s,
          ~w(fdgacbe cefdb cefbgd gcbe)s
        )
      ]

      assert DigitReader.count_simple_outputs(digits) == 2
    end

    test "with larger input" do
      digits = [
        DigitReader.Digits.build(
          ~w(be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb)s,
          ~w(fdgacbe cefdb cefbgd gcbe)s
        ),
        DigitReader.Digits.build(
          ~w(edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec)s,
          ~w(fcgedb cgb dgebacf gc)s
        ),
        DigitReader.Digits.build(
          ~w(fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef)s,
          ~w(cg cg fdcagb cbg)s
        ),
        DigitReader.Digits.build(
          ~w(fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega)s,
          ~w(efabcd cedba gadfec cb)s
        ),
        DigitReader.Digits.build(
          ~w(aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga)s,
          ~w(gecf egdcabf bgf bfgea)s
        ),
        DigitReader.Digits.build(
          ~w(fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf)s,
          ~w(gebdcfa ecba ca fadegcb)s
        ),
        DigitReader.Digits.build(
          ~w(dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf)s,
          ~w(cefg dcbef fcge gbcadfe)s
        ),
        DigitReader.Digits.build(
          ~w(bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd)s,
          ~w(ed bcgafe cdgba cbgef)s
        ),
        DigitReader.Digits.build(
          ~w(egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg)s,
          ~w(gbdfcae bgc cg cgb)s
        ),
        DigitReader.Digits.build(
          ~w(gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc)s,
          ~w(fgae cfgab fg bagce)s
        )
      ]

      assert DigitReader.count_simple_outputs(digits) == 26
    end
  end

  describe "decode_signals/1" do
    test "test" do
      decoded_signal =
        DigitReader.Digits.build(
          ~w(acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab)s,
          ~w(cdfeb fcadb cdfeb cdbaf)s
        )
        |> DigitReader.decode_signals()

      assert decoded_signal == %{
               8 => "acedgfb",
               5 => "cdfbe",
               2 => "gcdfa",
               3 => "fbcad",
               7 => "dab",
               9 => "cefabd",
               6 => "cdfgeb",
               4 => "eafb",
               0 => "cagedb",
               1 => "ab"
             }
    end
  end

  describe "decode_output/1" do
    test "test" do
      digit =
        DigitReader.Digits.build(
          ~w(acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab)s,
          ~w(cdfeb fcadb cdfeb cdbaf)s
        )

      decoded_signal = %{
        8 => "acedgfb",
        5 => "cdfbe",
        2 => "gcdfa",
        3 => "fbcad",
        7 => "dab",
        9 => "cefabd",
        6 => "cdfgeb",
        4 => "eafb",
        0 => "cagedb",
        1 => "ab"
      }

      assert DigitReader.decode_output(digit, decoded_signal) == 5353
    end
  end
end
