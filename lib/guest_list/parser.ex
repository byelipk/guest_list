defmodule GuestList.Parser do

  @filename "guest-list.rtf"

  def parse() do
    parsed =
      "./data/#{@filename}"
      |> Path.expand()
      |> File.read!()
      |> :jerome.parse(:rtf)

    {:ok, parsed}
  end
end
