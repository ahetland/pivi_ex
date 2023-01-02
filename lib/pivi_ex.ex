defmodule PiviEx do

  @moduledoc """
  Documentation for `PiviEx`.

  Creates a pivot table from a list.

  The strcut holds its original data in the data attribute.

    data
    |> pivot(fn r -> {r.company_id, r.account_id} end,
             fn r -> {Period.period(r.date)} end,
             fn r -> Decimal.sub(r.debit, r.credit) end)
  """

  @me __MODULE__

  alias PiviEx.Period

  defstruct(
    data: nil,
    row_sum: %{},
    col_sum: %{},
    element: %{},
    total: nil,
    info: nil,
  )

  def new({:ok, %{rows: rows, columns: columns}}) do
    data = 
      Enum.map(rows, fn r -> 
          Enum.zip(columns, r) |> Enum.into(%{}) end)
    %@me{data: data}
  end

  def new(data) do
  	%@me{data: data}
  end
  def new(data, info) do
  	%@me{data: data, info: info}
  end


  @doc """
    data
    |> pivot(fn r -> {r.company_id, r.account_id} end,
             fn r -> {Period.period(r.date)} end,
             fn r -> Decimal.sub(r.debit, r.credit) end)
  """
  def pivot(%@me{data: data, info: info} = _pi, row, col, amount) do
    _pivot(data, row, col, amount, new(data, info))
  end

  def pivot(lst, row, col, amount) when is_list(lst) do
  	_pivot(lst, row, col, amount, new(lst))
  end

  defp _pivot([], _row, _col, _amount, stu) do
    col_sum = 
      stu.element
      |> Enum.reduce(%{}, fn {{_, col}, amount}, acc -> 
                            Map.update(acc, col, amount, &(Decimal.add(&1, amount))) 
                          end
      )

    row_sum = 
      stu.element
      |> Enum.reduce(%{}, fn {{row, _}, amount}, acc -> 
                            Map.update(acc, row, amount, &(Decimal.add(&1, amount))) 
                          end
      )

    total = Enum.reduce(Map.values(col_sum), 0, &(Decimal.add(&1, &2)))

    %{stu | col_sum: col_sum, row_sum: row_sum, total: total}
  end

  #this branch allows for passing a row and column tuple instead of a function
  defp _pivot([h | t], row, col, amount, stu) do
    row_h = build_piv(h, row) || row.(h)
    col_h = build_piv(h, col) || col.(h)
    amount_h = if amount.(h)==nil, do: Decimal.new(0), else: amount.(h)

    calculate_element = 
      Map.update(stu.element, {row_h, col_h}, amount_h, &(Decimal.add(&1, amount_h)))

    stu = Map.put(stu, :element, calculate_element)

    _pivot(t, row, col, amount, stu)
  end

#  defp _pivot([h | t], row, col, amount, stu) do
#    row_h = row.(h)
#    col_h = col.(h)
#    amount_h = if amount.(h)==nil, do: Decimal.new(0), else: amount.(h)
#
#    calculate_element = 
#      Map.update(stu.element, {row_h, col_h}, amount_h, &(Decimal.add(&1, amount_h)))
#
#    stu = Map.put(stu, :element, calculate_element)
#
#    _pivot(t, row, col, amount, stu)
#  end

  defp empty_table_cells(%@me{} = me) do
    hd(Map.keys(me.row_sum))
    |> Tuple.to_list()
    |> Enum.map(fn _ -> nil end)
  end

  defp build_piv(r, {a}) do
    {Map.get(r, a)}
  end
  defp build_piv(r, {a, b}) do
    {Map.get(r, a), Map.get(r, b)}
  end
  defp build_piv(r, {a, b, c}) do
    {Map.get(r, a), Map.get(r, b), Map.get(r, c)}
  end
  defp build_piv(r, {a, b, c, d}) do
    {Map.get(r, a), Map.get(r, b), Map.get(r, c), Map.get(r, d)}
  end
  defp build_piv(r, {a, b, c, d, e}) do
    {Map.get(r, a), Map.get(r, b), Map.get(r, c), Map.get(r, d), Map.get(r, e)}
  end
  defp build_piv(r, _) do
#    {:error, "max in tuple"}
    false
  end

  @doc """
  Returns the header for the calculated elements.
  Optionally add a list of titles to the row elements.
  """
  def head_as_list(%@me{} = me) do
    head_list =  Map.keys(me.col_sum)
    lst = 
      for head <- head_list do
        Tuple.to_list(head) |> Enum.join("-") 
      end

    empty_table_cells(me) ++ lst ++ ["Total"]
  end

  def head_as_list(%@me{} = me, row_titles) when is_list(row_titles) do
    head_list =  Map.keys(me.col_sum) |> Enum.sort()
    lst = 
      for head <- head_list do
        Tuple.to_list(head) |> Enum.join("-") 
      end

    row_titles ++ lst ++ ["Total"]
  end

  def footer_as_list(%@me{} = me) do
    head_list =  Map.keys(me.col_sum) |> Enum.sort()
    lst = 
      for head <- head_list do
        Map.get(me.col_sum, head, Decimal.new(0))
      end
    empty_table_cells(me) ++ lst ++ [me.total]
  end
    
  defp row_as_list(%@me{} = me, row) do
    head_list =  Map.keys(me.col_sum) |> Enum.sort()
    lst = 
      for head <- head_list do
        Map.get(me.element, {row, head}, Decimal.new(0))
      end
    #[row | lst ] ++ [Map.get(me.row_sum, row)]
    Tuple.to_list(row) ++ lst ++ [Map.get(me.row_sum, row)]
  end

  defp row_as_map(%@me{} = me, row) do
    head_list =  Map.keys(me.col_sum) |> Enum.sort()
    lst = 
      for head <- head_list do
        v = Map.get(me.element, {row, head}, Decimal.new(0))
        %{value: v, col: head, row: row}
      end
    #[row | lst ] ++ [Map.get(me.row_sum, row)]
    Tuple.to_list(row) ++ lst ++ [%{value: Map.get(me.row_sum, row), row: row}]
  end

  def elements_as_list(%@me{} = me) do
    row_list =  Map.keys(me.row_sum) |> Enum.sort()

    for row <- row_list do
      row_as_list(me, row)
    end
  end

  def elements_as_map(%@me{} = me) do
    row_list =  Map.keys(me.row_sum) |> Enum.sort()

    for row <- row_list do
      row_as_map(me, row)
    end
    |> Enum.sort()
  end

  def as_list(%@me{} = me) do
    [head_as_list(me)] ++ elements_as_list(me) ++ [footer_as_list(me)]
  end

  def as_map(%@me{} = me) do
    elements_as_map(me) ++ [footer_as_list(me)]
  end

  def filter(%@me{data: data, info: info}, func) do
    Enum.filter(data, func)
    |> new(info)
  end

  @doc """
  Get the result of an element in the pivot table.

  When there is only one kw in the list then return the matching element.
  """
  def get(%@me{data: data} = me, opts) do

    data
    |> Enum.map(fn r -> map_a_kwl_to_map(opts, r) end)
    |> Enum.filter(& &1)
  end

  defp map_a_kwl_to_map([h], elem_map) do
    {k, v} = h
    if Map.get(elem_map, k) == v, do: elem_map
  end
  defp map_a_kwl_to_map([h | t], elem_map) do
    {k, v} = h
    if Map.get(elem_map, k) == v do
      map_a_kwl_to_map(t, elem_map)
    end
  end
  
  @doc """
  Get the result of an element in the pivot table and 
  sum these with the field provided in summation_field.
  """
  def get_and_sum(%@me{data: data} = me, summation_field, opts) do
    filtered_records = get(me, opts)
    Enum.reduce(filtered_records, Decimal.new(0), 
      fn r, acc -> get_and_sum_adder(r, acc, summation_field) end)
  end
  defp get_and_sum_adder(r, acc, summation_field) do
    val = 
      case Map.get(r, summation_field) do
        nil -> Decimal.new(0)
        x -> x
      end
    Decimal.add(val, acc)
  end


  @doc """
  Export the data to a CSV list by providing a list of field atoms
  converts the underlying data to list.
  Usage:
  
  csv = 
    %PiviEx{}
    |> to_csv()

  File.wite("/tmp/example.csv", csv)
  """
  def to_csv(%@me{data: data}, header) do
    data
    |> Enum.reduce([header], fn d, acc ->
                          row = Enum.map(header, fn h ->
                                                  Map.get(d, h) 
                                                  end)
                          [row | acc] 
    end)
    |> Enum.reverse()
    |> CSV.encode(separator: ?;)
    |> Enum.to_list()

  end
  def to_csv(%@me{data: data} = me) do
    header = hd(data) |> Map.keys()
    to_csv(me, header)
  end

  def csv_test() do
    test2()
    |> to_csv([:company_id, :amount])
  end

  def test() do
    data2()
    |> pivot(fn r -> {r.account_id, r.company_id} end,
             fn r -> {Period.period(r.date)} end,
             fn r -> Decimal.sub(r.debit, r.credit) end)
  end

  def test3() do
    test()

    data2()
    |> pivot(fn r -> {r.account_id, nil} end,
             fn r -> {Period.period(r.date)} end,
             fn r -> Decimal.sub(r.debit, r.credit) end)
  end

  @doc """
  Combine two Pivis to create list with sub totals

  Create two Pivis with same size and join them.
  """
  def test_combine() do
    a = PiviEx.test3 |> PiviEx.elements_as_map
    b = PiviEx.test |> PiviEx.elements_as_map
    (a ++ b) |> Enum.sort()
  end

  defp data do
    [
      %{company_id: 1, gender: "m", account_id: "Acc. #1", 
        date: ~D[2020-06-05], amount: Decimal.new(15)},
      %{company_id: 1, gender: "m", account_id: "Acc. #1", 
        date: ~D[2020-06-05], amount: nil},
      %{company_id: 1, gender: "f", account_id: "Acc. #1", 
        date: ~D[2020-06-05], amount: Decimal.new(15)},
      %{company_id: 1, gender: "m", account_id: "Acc. #1", 
        date: ~D[2020-06-05], amount: Decimal.new(15)},
      %{company_id: 2, gender: "f", account_id: "Acc. #1", 
        date: ~D[2020-06-05], amount: Decimal.new(15)},
      %{company_id: 2, gender: "f", account_id: "Acc. #2", 
        date: ~D[2020-06-05], amount: Decimal.new(15)},
    ]
  end
  defp data2 do
    [
      %{company_id: 3, account_id: "Acc. #2", date: ~D[2020-03-05], 
        debit: Decimal.new(10), credit: Decimal.new(0)},
      %{company_id: 3, account_id: "Acc. #2", date: ~D[2020-03-05], 
        debit: Decimal.new(10), credit: Decimal.new(0)},
      %{company_id: 3, account_id: "Acc. #2", date: ~D[2020-03-05], 
        debit: 0, credit: Decimal.new(0)},
      %{company_id: 1, account_id: "Acc. #1", date: ~D[2020-05-05], 
        debit: Decimal.new(10), credit: Decimal.new(0)},
      %{company_id: 2, account_id: "Acc. #1", date: ~D[2020-05-05], 
        debit: Decimal.new(10), credit: Decimal.new(0)},
      %{company_id: 1, account_id: "Acc. #1", date: ~D[2020-05-05], 
        debit: Decimal.new(10), credit: Decimal.new(0)},
      %{company_id: 1, account_id: "Acc. #1", date: ~D[2020-03-05], 
        debit: Decimal.new("10.7"), credit: Decimal.new(0)},
      %{company_id: 1, account_id: "Acc. #1", date: ~D[2020-05-05], 
        debit: Decimal.new(8), credit: Decimal.new(0)},
      %{company_id: 1, account_id: "Acc. #1", date: ~D[2020-06-05], 
        debit: Decimal.new(8), credit: Decimal.new(0)},
      %{company_id: 1, account_id: "Acc. #1", date: ~D[2020-06-05], 
        debit: Decimal.new(8), credit: Decimal.new(0)},
      %{company_id: 1, account_id: "Acc. #1", date: ~D[2020-06-05], 
        debit: Decimal.new(8), credit: Decimal.new(0)},
      %{company_id: 1, account_id: "Acc. #1", date: ~D[2020-03-05], 
        debit: Decimal.new(10), credit: Decimal.new(0)},
      %{company_id: 2, account_id: "Acc. #1", date: ~D[2020-03-05], 
        debit: Decimal.new(10), credit: Decimal.new(0)},
    ]
  end
  def test2() do
    data()
    |> pivot(fn r -> {r.company_id, r.account_id} end,
             fn r -> {Period.period(r.date), r.gender} end,
             fn r -> r.amount end)
  end
    

end

