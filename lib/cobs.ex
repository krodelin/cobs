defmodule Cobs do
  @moduledoc """
  Elixir implementation of [Consistent Overhead Byte Stuffing](https://en.wikipedia.org/wiki/Consistent_Overhead_Byte_Stuffing)
  """

  @doc """
  Convert a binary (with `0` bytes) into a COBS encoded binary (without `0` bytes).
  """


  def encode(binary) do
    do_encode(<<>>, binary)
  end

  defp do_encode(head, <<>>) do
    ohb = byte_size(head) + 1
    <<ohb>> <> head
  end

  defp do_encode(head, <<0, tail :: binary>>) do
    ohb = byte_size(head) + 1
    <<ohb>> <> head <> do_encode(<<>>, tail)
  end

  defp do_encode(head, <<val, tail :: binary>>) do
    do_encode(head <> <<val>>, tail)
  end


  def decode(<<>>) do
    <<>>
  end

  def decode(<<ohb, tail :: binary>>) do
    head_length = ohb - 1
    <<block :: binary - size(head_length), remaining :: binary>> = tail
    if byte_size(remaining) > 0, do: block <> <<0>> <> decode(remaining), else: block
  end
end