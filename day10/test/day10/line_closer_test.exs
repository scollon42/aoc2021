defmodule Day10.LineCloserTest do
  use ExUnit.Case

  alias Day10.LineCloser

  describe "try_close/1" do
    test "with closed line do nothing" do
      assert [] = LineCloser.try_close("()")
    end

    test "with broken line do nothing" do
      assert [] = LineCloser.try_close("(}")
    end

    test "with unfinished line returns closing braces" do
      assert [")"] = LineCloser.try_close("(")
    end

    test "with longer line should returns all, ordered, closing braces" do
      assert ["}", "}", "]", "]", ")", "}", ")", "]"] =
               LineCloser.try_close("[({(<(())[]>[[{[]{<()<>>")
    end
  end
end
