defmodule PiviEx2.Test do

  @moduledoc """
  I want to test if I can add arbitrary (Structs) objects to 
  the pivot. 
  """

  def data() do
    #1055 
    [
      %{a: "apple", b: "yellow", 
        cost: Decimal.new("20.00"), revenue: Decimal.new("50.0")},
      %{a: "orange", b: "yellow", 
        cost: Decimal.new("20.00"), revenue: Decimal.new("40.00")},
      %{a: "apple", b: "green", 
        cost: Decimal.new("15.00"), revenue: Decimal.new("15.50")},
      %{a: "apple", b: "yellow", 
        cost: Decimal.new("500.00"), revenue: Decimal.new("1200.50")},
      %{a: "bannana", b: "yellow", 
        cost: Decimal.new("200.00"), revenue: Decimal.new("300.00")},
      %{a: "apple", b: "yellow", 
        cost: Decimal.new("300.00"), revenue: Decimal.new("500.00")},
    ]
  end

  def test do
    data = data()
    
    PiviEx.new(data)
    |> PiviEx.pivot(
      fn r -> {r.a} end,
      fn r -> {r.b} end,
      #fn r -> %{revenue: Decimal.new(0), cost: Decimal.new(0)} end,
     # fn r -> %{revenue: r.revenue, cost: r.cost} end,
      fn r -> r end,
      fn a, b ->
        rev_a = Map.get(a, :revenue, Decimal.new(0))
        cost_a = Map.get(a, :cost, Decimal.new(0))
        #rev_b = Map.get(b, :revenue, Decimal.new(0))
        Map.update(b, :revenue, 
          rev_a, fn exis -> 
            Decimal.add(exis, rev_a) 
        end)
          |> Map.update(:cost,
          cost_a, fn exis -> 
            Decimal.add(exis, cost_a) 
        end)
      end
    )
  end

  def test2() do
    PiviEx.new(data())
    |> PiviEx.pivot(
      fn r -> {r.a} end,
      fn r -> {r.b} end,
      fn r -> r.cost end
    )
  end


end

