defmodule Day10.LineParserTest do
  use ExUnit.Case

  alias Day10.LineParser

  describe "parse/1" do
    test "with simple brace should be ok" do
      assert {:ok, []} = LineParser.parse("()")
    end

    test "with simple nested brace should be ok" do
      assert {:ok, []} = LineParser.parse("({})")
    end

    test "with unclosed brace should be ok and returns unclosed stack" do
      assert {:ok, ["("]} = LineParser.parse("({}")
    end

    test "with unexpected brace should return an error" do
      assert {:error, ")"} = LineParser.parse("({)}")
    end

    test "with multiple error should return the first one" do
      assert {:error, "}"} = LineParser.parse("<()<}>)>")
    end

    test "with more complexe pattern and an error" do
      assert {:error, "}"} = LineParser.parse("{([(<{}[<>[]}>{[]{[(<()>")
    end
  end
end
