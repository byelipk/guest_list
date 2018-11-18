defmodule GuestList.Aggregator do

  alias GuestList.{Parser, Sanitizer}

  defdelegate clean(rtf), to: Sanitizer

  def parse() do
    {:ok, parsed } = Parser.parse()
    parsed
    |> clean()
    |> Enum.with_index()
  end

  def aggregate() do
    parse()
    |> aggregate_lines()
  end

  def emails() do
    parse()
    |> Enum.filter(&is_email?(&1))
  end

  def names() do
    parse()
    |> Enum.reject(&is_email?(&1))
  end

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

  defp is_email?({ {_, _, [hyperlink: _]}, _}), do: true
  defp is_email?(_), do: false


end
