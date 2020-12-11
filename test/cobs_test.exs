defmodule CobsTest do
  use ExUnit.Case
  doctest Cobs

  test "encode empty", do: assert(Cobs.encode(<<>>) == {:ok, <<0x01>>})
  test "decode empty", do: assert(Cobs.decode(<<0x01>>) == {:ok, <<>>})

  test "encode 1", do: assert(Cobs.encode(<<0x01>>) == {:ok, <<0x02, 0x01>>})
  test "decode 1", do: assert(Cobs.decode(<<0x02, 0x01>>) == {:ok, <<0x01>>})

  test "encode 0", do: assert(Cobs.encode(<<0x00>>) == {:ok, <<0x01, 0x01>>})
  test "decode 0", do: assert(Cobs.decode(<<0x01, 0x01>>) == {:ok, <<0x00>>})

  test "encode double 0", do: assert(Cobs.encode(<<0x00, 0x00>>) == {:ok, <<0x01, 0x01, 0x01>>})
  test "decode double 0", do: assert(Cobs.decode(<<0x01, 0x01, 0x01>>) == {:ok, <<0x00, 0x00>>})

  test "encode middle 0",
    do: assert(Cobs.encode(<<0x01, 0x02, 0x00, 0x03>>) == {:ok, <<0x03, 0x01, 0x02, 0x02, 0x03>>})

  test "decode middle 0",
    do: assert(Cobs.decode(<<0x03, 0x01, 0x02, 0x02, 0x03>>) == {:ok, <<0x01, 0x02, 0x00, 0x03>>})

  test "encode no 0",
    do: assert(Cobs.encode(<<0x01, 0x02, 0x03, 0x04>>) == {:ok, <<0x05, 0x01, 0x02, 0x03, 0x04>>})

  test "decode no 0",
    do: assert(Cobs.decode(<<0x05, 0x01, 0x02, 0x03, 0x04>>) == {:ok, <<0x01, 0x02, 0x03, 0x04>>})

  test "encode tripple 0",
    do: assert(Cobs.encode(<<0x01, 0x00, 0x00, 0x00>>) == {:ok, <<0x02, 0x01, 0x01, 0x01, 0x01>>})

  test "decode tripple 0",
    do: assert(Cobs.decode(<<0x02, 0x01, 0x01, 0x01, 0x01>>) == {:ok, <<0x01, 0x00, 0x00, 0x00>>})

  test "encode too long" do
    {return, _} = Cobs.encode(<<-1::unit(8)-size(254)>>)
    assert return == :ok
    {return, _} = Cobs.encode(<<-1::unit(8)-size(255)>>)
    assert return == :error
    {return, _} = Cobs.encode(<<-1::unit(8)-size(256)>>)
    assert return == :error
  end

  test "encode too long exception" do
    assert_raise ArgumentError, fn -> Cobs.encode!(<<-1::unit(8)-size(255)>>) end
  end

  test "decode invalid" do
    {return, _} = Cobs.decode(invalid_data())
    assert return == :error
  end

  test "decode invalid exception" do
    assert_raise ArgumentError, fn -> Cobs.decode!(invalid_data()) end
  end

  defp invalid_data() do
    {:ok, valid} = Cobs.encode(<<-1::unit(8)-size(253)>>)
    # The appended binary specifies ten remaining bytes although only one is present
    valid <> <<10, 0>>
  end
end
