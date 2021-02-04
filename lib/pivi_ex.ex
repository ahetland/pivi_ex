defmodule PiviEx do

  @moduledoc """
  Documentation for `PiviEx`.

  Creates a pivot table from a list.

  The strcut holds its original data in the data attribute.
  """

  @me __MODULE__

  alias PiviEx.Period

  defstruct(
    data: nil,
    row_sum: %{},
    col_sum: %{},
    element: %{},
    total: nil
  )

  def new(data) do
  	%@me{data: data}
  end

  @doc """
    data
    |> pivot(fn r -> {r.company_id, r.account_id} end,
             fn r -> {Period.period(r.date)} end,
             fn r -> Decimal.sub(r.debit, r.credit) end)
  """

  def pivot(%@me{data: data} = pi, row, col, amount) do
    _pivot(data, row, col, amount, new(data))
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

  defp _pivot([h | t], row, col, amount, stu) do
    row_h = row.(h)
    col_h = col.(h)
    amount_h = if amount.(h)==nil, do: Decimal.new(0), else: amount.(h)

    calculate_element = 
      Map.update(stu.element, {row_h, col_h}, amount_h, &(Decimal.add(&1, amount_h)))

    stu = Map.put(stu, :element, calculate_element)

    _pivot(t, row, col, amount, stu)
  end

  defp empty_table_cells(%@me{} = me) do
    hd(Map.keys(me.row_sum))
    |> Tuple.to_list()
    |> Enum.map(fn _ -> nil end)
  end

  def head_as_list(%@me{} = me) do
    head_list =  Map.keys(me.col_sum)
    lst = 
      for head <- head_list do
        Tuple.to_list(head) |> hd
      end

    empty_table_cells(me) ++ lst ++ ["Total"]
  end

  def footer_as_list(%@me{} = me) do
    head_list =  Map.keys(me.col_sum)
    lst = 
      for head <- head_list do
        Map.get(me.col_sum, head, Decimal.new(0))
      end
    empty_table_cells(me) ++ lst ++ [me.total]
  end
    
  defp row_as_list(%@me{} = me, row) do
    head_list =  Map.keys(me.col_sum)
    lst = 
      for head <- head_list do
        Map.get(me.element, {row, head}, Decimal.new(0))
      end
    #[row | lst ] ++ [Map.get(me.row_sum, row)]
    Tuple.to_list(row) ++ lst ++ [Map.get(me.row_sum, row)]
  end

  defp row_as_map(%@me{} = me, row) do
    head_list =  Map.keys(me.col_sum)
    lst = 
      for head <- head_list do
        v = Map.get(me.element, {row, head}, Decimal.new(0))
        %{value: v, col: head, row: row}
      end
    #[row | lst ] ++ [Map.get(me.row_sum, row)]
    Tuple.to_list(row) ++ lst ++ [%{value: Map.get(me.row_sum, row), row: row}]
  end

  def elements_as_list(%@me{} = me) do
    row_list =  Map.keys(me.row_sum)

    for row <- row_list do
      row_as_list(me, row)
    end
  end

  def elements_as_map(%@me{} = me) do
    row_list =  Map.keys(me.row_sum)

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

  def test(data) do
    data
    |> pivot(fn r -> {r.company_id, r.account_id} end,
             fn r -> {Period.period(r.date)} end,
             fn r -> Decimal.sub(r.debit, r.credit) end)
    
  end

  def test() do
    data = [
      %{company_id: 3, account_id: "Acc. #2", date: ~D[2020-07-05], debit: Decimal.new(10), credit: Decimal.new(0)},
      %{company_id: 3, account_id: "Acc. #2", date: ~D[2020-03-05], debit: Decimal.new(10), credit: Decimal.new(0)},
      %{company_id: 3, account_id: "Acc. #2", date: ~D[2020-03-05], debit: 0, credit: Decimal.new(0)},
      %{company_id: 1, account_id: "Acc. #1", date: ~D[2020-05-05], debit: Decimal.new(10), credit: Decimal.new(0)},
      %{company_id: 2, account_id: "Acc. #1", date: ~D[2020-05-05], debit: Decimal.new(10), credit: Decimal.new(0)},
      %{company_id: 1, account_id: "Acc. #1", date: ~D[2020-05-05], debit: Decimal.new(10), credit: Decimal.new(0)},
      %{company_id: 1, account_id: "Acc. #1", date: ~D[2020-05-05], debit: Decimal.new(8), credit: Decimal.new(0)},
      %{company_id: 1, account_id: "Acc. #1", date: ~D[2020-06-05], debit: Decimal.new(8), credit: Decimal.new(0)},
      %{company_id: 1, account_id: "Acc. #1", date: ~D[2020-06-05], debit: Decimal.new(8), credit: Decimal.new(0)},
      %{company_id: 1, account_id: "Acc. #1", date: ~D[2020-06-05], debit: Decimal.new(8), credit: Decimal.new(0)},
    ]
    test(data)
  end
  defp data do
    [
      %{company_id: 1, account_id: "Acc. #1", date: ~D[2020-06-05], amount: Decimal.new(15)},
      %{company_id: 1, account_id: "Acc. #1", date: ~D[2020-06-05], amount: nil},
      %{company_id: 1, account_id: "Acc. #1", date: ~D[2020-06-05], amount: Decimal.new(15)},
      %{company_id: 1, account_id: "Acc. #1", date: ~D[2020-06-05], amount: Decimal.new(15)},
    ]
  end
  def test2() do
    data()
    |> pivot(fn r -> {r.company_id, r.account_id} end,
             fn r -> {Period.period(r.date)} end,
             fn r -> r.amount end)
  end
    

end

