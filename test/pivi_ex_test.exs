defmodule PiviExTest do
  use ExUnit.Case
  doctest PiviEx
  alias PiviEx.Period

  test "the quarter returns a range" do
    assert Period.from_quarter("2021-Q1") == {:ok, 202101..202103}
    assert Period.from_quarter("2021-Q2") == {:ok, 202104..202106}
    assert Period.from_quarter("2021-Q3") == {:ok, 202107..202109}
    assert Period.from_quarter("2021-Q4") == {:ok, 202110..202112}
  end

  test "the quarter is placed in front" do
    assert Period.from_quarter("Q3-2021") == {:ok, 202107..202109}
  end
end
