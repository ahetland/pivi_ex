defmodule PiviExTest do
  use ExUnit.Case
  doctest PiviEx
  alias PiviEx.Period

  test "the quarter returns a range" do
    assert Period.from_quarter("2021-Q1") == 202101..202103
    assert Period.from_quarter("2021-Q2") == 202104..202106
    assert Period.from_quarter("2021-Q3") == 202107..202109
    assert Period.from_quarter("2021-Q4") == 202110..202112
  end
end
