defmodule GuestList.Sanitizer do

  def clean(rtf) do
    rtf
    |> Enum.map(&sanitize_line(&1))
    |> Enum.reject(&(
      is_empty?(&1) ||
      is_paragraph?(&1) ||
      looks_like_an_address?(&1) ||
      looks_like_a_comment?(&1)
    ))
  end

  defp sanitize_line({:text, text, []}) do
    new_line =
      text
      |> List.to_string()
      |> String.replace(~r/a0|\(|\)/, "")
      |> String.trim()

    {:text, new_line, []}
  end
  defp sanitize_line(line = {:text, _email, [hyperlink: _]}), do: line
  defp sanitize_line(line), do: line

  defp is_paragraph?({:paragraph, _}), do: true
  defp is_paragraph?(_), do: false

  defp looks_like_an_address?({:text, _, [hyperlink: _]}), do: false
  defp looks_like_an_address?({:text, text, []}) do
    String.match?(text, ~r/[0-9]+/)
  end

  defp looks_like_a_comment?({:text, text, []}) do
    String.match?(text, ~r/Dr|Ms|Mr|Grandpa|Miss|Sr/) == false
  end
  defp looks_like_a_comment?({:text, _, [hyperlink: _]}), do: false

  defp is_empty?(line) do
    elem(line, 1) == ""
  end
end
