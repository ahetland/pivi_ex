defmodule PiviEx.TwoTableDelta do

  @moduledoc """
  Takes two PiviEx strcuts and creates a delta report
  from the totals column.

  A default CSS style sheet is provided in the struct or 
  css styles can be set by redefining the classes.

  t = TwoTableDelta.new(x, y, 
  [{%{class: "th"}, "ID"}, "Name", "Left", "Right", "Ch.", "%"])
  """

  alias PiviEx
  @me __MODULE__

  defstruct(left: nil, 
    right: nil,
    map_set: nil,
    head_row: nil,
    foot_title: "Total"
  )

  def new(%PiviEx{row_sum: left}, %PiviEx{row_sum: right}, head_row) do
    %@me{left: left, right: right, 
      head_row: head_row,
      map_set: create_a_map_set(left, right)}
  end

  def as_table([k, l, r, _, _]) do
    as_table([k, l, r])
  end
  def as_table([k, l, r]) do
    ab = fn -> Decimal.sub(l, r) end
    pc = 
      fn -> 
        case Decimal.eq?(r, 0) do
          true -> "n.a."
          false -> 
            val = Decimal.div(ab.(), r) |> Decimal.mult(100)
            if (Decimal.gt?(val, 1000) or Decimal.lt?(val, -1000)) do
              ">1k"
            else
              val
            end
        end
      end

    [k, l, r, ab.(), pc.()]
  end

  def as_table(%@me{} = me) do
    l = fn k -> Map.get(me.left, k, Decimal.new(0)) end
    r = fn k -> Map.get(me.right, k, Decimal.new(0)) end
    ab = fn k -> Decimal.sub(l.(k), r.(k)) end
    fn k -> 
      case Decimal.eq?(r.(k), 0) do
        true -> "n.a."
        false -> 
          val = Decimal.div(ab.(k), r.(k)) |> Decimal.mult(100)
          if (Decimal.gt?(val, 1000) or Decimal.lt?(val, -1000)) do
            ">1k"
          else
            val
          end
      end
    end

    Enum.map(me.map_set, fn k -> [k, l.(k), r.(k)] end)
    |> Enum.map(&as_table(&1))

  end

  def as_sneeze_table(%@me{} = me) do
    body = 
      as_table(me)
      |> Enum.map(fn [t, l, r, abd, pc] ->
        [:tr, sz_td(t, %{class: "td-left"}) ++ [
          [:td, %{class: "td-right"}, fmt(l, 2)], 
          [:td, %{class: "td-right"}, fmt(r)], 
          [:td, %{class: "td-right italic"}, fmt(abd, 0)], 
          [:td, %{class: "td-right italic"}, fmt(pc, 1)]]
        ]
      end)

    body_sorted = 
      Enum.sort(body, fn [:tr, a], [:tr, b] -> a<=b end)

    [k, l, r, abd, pc] = footer(me)

    foot = 
      [:tr, sz_td(k, %{class: "sum-line font-bold"}) ++ [
        [:td, %{class: "sum-line td-right font-bold"}, fmt(l, 2)], 
        [:td, %{class: "sum-line td-right font-bold"}, fmt(r)], 
        [:td, %{class: "sum-line td-right italic font-bold"}, fmt(abd, 0)], 
        [:td, %{class: "sum-line td-right italic font-bold"}, fmt(pc, 1)]]
      ]

    head = [[:tr, %{class: "td-left border-bottom"}, sz_th(me.head_row)]] 

    [:table, %{class: "report"},
      head
      ++ body_sorted
      ++ foot
    ]
  end

  def footer(%@me{} = me) do
    [k, l, r, _ch, _pc] = 
      as_table(me)
      |> Enum.zip()

    [l, r] = 
      Enum.map([l, r], fn t -> 
        Tuple.to_list(t)
        |> Enum.reduce(Decimal.new(0), &(Decimal.add(&1, &2)))
      end)

    [_hd | lst] = 
      Tuple.to_list(k) 
      |> hd() 
      |> Tuple.to_list
      |> Enum.map(fn _ -> nil end)

    h = 
      [Map.get(me, :foot_title, "Sub total") | lst]
      |> List.to_tuple()

    as_table([h, l, r])
  end

  defp fmt(v) when is_binary(v), do: v
  defp fmt(v) do
    Number.Delimit.number_to_delimited(v, precision: 2)
  end

  defp fmt(v, _precission) when is_binary(v), do: v
  defp fmt(v, precision) do
    Number.Delimit.number_to_delimited(v, precision: precision)
  end

  defp sz_th(row) do
    row
    |> Enum.map(fn r ->
      case r do
        {k, v} -> [:th, k, v] 
        _ -> [:th, r] 
      end
    end)
  end

  defp sz_td(row, css) when is_tuple(row) do
    Tuple.to_list(row)
    |> Enum.map(&([:td, css, &1]))
  end

  defp create_a_map_set(left, right) do
    Map.keys(left) ++ Map.keys(right)
    |> MapSet.new()
  end

  def test do
    l = PiviEx.test2
    r = PiviEx.test2_2

    new(l, r, ["ID", "Name", "Left", "Right", "Change", "Pc%"])
  end
end

