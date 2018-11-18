defmodule GuestListTest do
  use ExUnit.Case
  doctest GuestList

  test "it parses rtf documents" do
    assert {:ok, parsed} = GuestList.parse()
  end

  test "it parses email addresses" do
    data = [
      {:text, 'email@example.org', [hyperlink: 'mailto:email@example.org']},
      {:text, 'email2@example.org', [hyperlink: 'mailto:email2@example.org']}
    ]
    assert ['email2@example.org', 'email@example.org'] = GuestList.parse_lines(data)
  end

  test "it ignores paragraph lines" do
    data = [
      {:paragraph, :left},
      {:paragraph, :left}
    ]
    assert [] = GuestList.parse_lines(data)
  end
end
