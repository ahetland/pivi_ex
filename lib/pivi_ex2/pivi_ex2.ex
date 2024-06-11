defmodule PiviEx2 do

  @moduledoc """
  Documentation for `PiviEx2`. A refactoring of `PiviEx`

  Creates a pivot table from a list.

    fun = fn x, y -> x.amount + y.amount end

    data
    |> pivot(fn r -> {r.company_id, r.account_id} end,
             fn r -> {Period.period(r.date)} end,
             fn r -> fun end)
  """

  @me __MODULE__


  defstruct(
    data: nil,
    element: %{}
  )

  def new(data) do
    %@me{data: data}
  end

  def pivot(%@me{data: data} = me, row, col, fun, init_value) do
    pivot_(me, row, col, fun, init_value, data)
  end

  defp pivot_(me, _row, _col, _fun, _init_value, []) do
    me
  end

  defp pivot_(%@me{} = me, row, col, fun, init_value, [h | tl] = _accum) do
    row_key = row.(h)
    col_key = col.(h)
    key = {row_key, col_key}

#    IO.puts "....."
    fun_closure = fun.(h)
#    IO.inspect fun_closure
    value = Map.get(me.element, key, init_value)
#    IO.inspect value
#    IO.inspect fun_closure.(value)
#    IO.puts "....."

    new_element = 
      Map.put(me.element, key, fun_closure.(value))

    new_me = Map.put(me, :element, new_element)

    pivot_(new_me, row, col, fun, init_value, tl) 
  end

  def piv_fun(r) do
    ex = r.amount
    # IO.puts "The value of r stored in the closure: -#{inspect r}-#{ex}-"
    fn val_on_key -> Decimal.add(val_on_key, ex) end
  end

  def piv_fun_2(r) do
    ex = r.amount
    fn val_on_key -> 
      [:td, [:a, m, x]] = val_on_key
      y = Decimal.add(x, ex)
      [:td, [:a, %{href: "#{r["A"]}"}, y]]
    end
  end


  def test do
    data = [
      %{"A" => "apple", "B" => "yellow", amount: Decimal.new("5.0")},
      %{"A" => "orange", "B" => "yellow", amount: Decimal.new("44.56")},
      %{"A" => "apple", "B" => "green", amount: Decimal.new("15.5")},
      %{"A" => "apple", "B" => "yellow", amount: Decimal.new("1244.01")},
      %{"A" => "bannana", "B" => "yellow", amount: Decimal.new("344.56")},
      %{"A" => "apple", "B" => "yellow", amount: Decimal.new("0.02")},
    ]
    
    new(data)
    |> pivot(
      fn r -> {r["A"]} end,
      fn r -> r["B"] end,
      fn r -> piv_fun_2(r) end,
      [:td, [:a, %{href: nil}, Decimal.new(0)]]
    )
  end

end

