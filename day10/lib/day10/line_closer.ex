defmodule Day10.LineCloser do
  alias Day10.LineParser

  # @spec parse(String.t()) :: :ok, {:error, char}
  def try_close(line) do
    chars = String.codepoints(line)

    case LineParser.parse(chars) do
      {:ok, []} ->
        []

      {:error, _} ->
        []

      {:ok, stack} ->
        Enum.map(stack, &close/1)
    end
  end

  defp close("("), do: ")"
  defp close("<"), do: ">"
  defp close("{"), do: "}"
  defp close("["), do: "]"
end
