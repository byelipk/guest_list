defmodule GuestList.Parser do

  @filename "guest-list.rtf"

  def parse() do
    @filename
    |> parse()
    |> aggregate()
  end

  def emails() do
    {:ok, parsed } = parse(@filename)
    parsed
    |> Enum.with_index()
    |> Enum.filter(&is_email?(&1))
  end

  def names() do
    {:ok, parsed } = parse(@filename)
    parsed
    |> Enum.with_index()
    |> Enum.reject(&is_email?(&1))
  end

  defp aggregate({:ok, parsed}) do
    parsed
    |> Enum.with_index()
    |> aggregate_lines()
  end

  defp parse(filename) do
    parsed =
      "./data/#{filename}"
      |> Path.expand()
      |> File.read!()
      |> :jerome.parse(:rtf)
      |> clean()

    {:ok, parsed}
  end

  defp clean(rtf) do
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

  defp is_email?({ {_, _, [hyperlink: _]}, _}), do: true
  defp is_email?(_), do: false

  defp aggregate_lines(collection) do
    collection
    |> Enum.reduce([], fn(line, acc) ->
      case line do
        # We matched against an email address, so let's
        # add a new entry.
        { {:text, email, [hyperlink: _]}, index} ->
          { {:text, name, _}, _} = Enum.at(collection, index-1)
          [ { email, [ name ] } | acc ]

        # We matched against a name.
        { {:text, name, []}, index } ->
          cond do
            # Empty accumulator, so let's skip.
            Enum.empty?(acc) ->
              acc

            # The next element in the list after the current one
            # is a link, so let's skip.
            is_email?(Enum.at(collection, index+1)) ->
              acc

            # Prepend name to list.
            true ->
              [ { email, names } | tail ] = acc
              [ {email, [name | names]} | tail ]

          end
      end
    end)
  end
end
