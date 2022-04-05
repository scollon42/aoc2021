defmodule Day10.LineParser do
  @opening_chars ["(", "[", "{", "<"]

  # @spec parse(String.t()) :: :ok, {:error, char}
  def parse(line) when is_binary(line) do
    line
    |> String.codepoints()
    |> parse()
  end

  def parse(chars) when is_list(chars) do
    chars
    |> Enum.reduce_while({:ok, []}, fn
      char, {:ok, []} ->
        if Enum.member?(@opening_chars, char) do
          {:cont, {:ok, [char]}}
        else
          {:halt, {:error, char}}
        end

      char, {:ok, [last | rest] = stack} ->
        cond do
          Enum.member?(@opening_chars, char) -> {:cont, {:ok, [char | stack]}}
          closes?(char, last) -> {:cont, {:ok, rest}}
          true -> {:halt, {:error, char}}
        end
    end)
  end

  defp closes?(char, last_char) do
    case last_char do
      "(" -> char == ")"
      "{" -> char == "}"
      "[" -> char == "]"
      "<" -> char == ">"
    end
  end
end
