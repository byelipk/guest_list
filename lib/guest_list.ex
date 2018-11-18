defmodule GuestList do
  alias GuestList.{Parser}

  defdelegate parse(), to: Parser
  defdelegate names(), to: Parser
  defdelegate emails(), to: Parser

  def print(:names) do
    Enum.each(names(), fn({{ _, name, _ }, _}) ->
      IO.puts(name)
    end)
  end

  def print(:emails) do
    Enum.each(emails(), fn({{ _, email, _ }, _}) ->
      IO.puts(email)
    end)
  end
end
