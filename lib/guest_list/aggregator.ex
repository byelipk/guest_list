defmodule GuestList.Aggregator do

  alias GuestList.{Parser, Sanitizer}

  defdelegate parse(), to: Parser
  defdelegate clean(rtf), to: Sanitizer

  def aggregate() do
    {:ok, parsed } = parse()
    parsed
    |> clean()
    |> Enum.with_index()
    |> aggregate_lines()
  end

  def emails() do
    {:ok, parsed } = parse()
    parsed
    |> clean()
    |> Enum.with_index()
    |> Enum.filter(&is_email?(&1))
  end

  def names() do
    {:ok, parsed } = parse()
    parsed
    |> clean()
    |> Enum.with_index()
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
