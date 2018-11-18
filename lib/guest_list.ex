defmodule GuestList do
  alias GuestList.{Aggregator}

  def names() do
    Aggregator.names()
    |> Enum.each(fn({{ _, name, _ }, _}) ->
      IO.puts(name)
    end)
  end

  def emails() do
    Aggregator.emails()
    |> Enum.each(fn({{ _, email, _ }, _}) ->
      IO.puts(email)
    end)
  end

  def aggregate() do
    Aggregator.aggregate()
    |> Enum.each(fn(line) ->
      IO.inspect(line)
    end)
  end
end
