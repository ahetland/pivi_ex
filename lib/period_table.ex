defmodule PiviEx.PeriodTable do
  @moduledoc """
  Takes a single PiviEx struct and creates a period view
  with the head row as periods.
  """

  alias PiviEx
  import PiviEx.Helper
  @me __MODULE__

  defstruct(pivi: nil,
    body: nil,
    footer: nil,
    header: nil,
    head_list: nil,
    foot_title: "Total",
    css_table: %{class: "report"},
    css_tr: %{class: "tr-cls"},
    css_td: %{class: "td-right td-element"},
    css_th_left: %{class: "css_th_left td-left font-bold-1 border-bottom"},
    css_th_right: %{class: "css_th_right td-right font-bold-1 border-bottom"},
    css_td_left: %{class: "td-left"},
    css_map: %{
      {:key_of_the_row, :x} => %{class: "the css to use"}
    }
  )

  def new(%PiviEx{} = pivi, head_list) do
    %@me{pivi: pivi,
      body: PiviEx.elements_as_list2(pivi),
      head_list: head_list,
      header: PiviEx.head_as_list(pivi, head_list),
      footer: PiviEx.footer_as_list(pivi)
    }
  end

  @doc"""
  Add subtotals to the body by providing
  a filter for the row elements which will 
  then be added. A tuple for the row must also
  be provided.
  The body is sorted again.
  """
  def sub_total(%@me{} = me, row_name, css_map, filter_fn) do
    filtered = 
      me.body
      |> Enum.filter(fn [c | _r] -> filter_fn.(c) end)

    [_h | t] = Enum.zip(filtered)

    result = 
      Enum.map(t, fn r ->
        Enum.reduce(Tuple.to_list(r), Decimal.new(0), 
          fn rr, acc -> Decimal.add(rr, acc) end) 
      end)

    new_body = 
      [[row_name] ++ result] ++ me.body

    new_css = Map.put(me.css_map, row_name, css_map)

    Map.put(me, :body, Enum.sort(new_body))
    |> Map.put(:css_map, new_css)
  end

  def thead(%@me{} = me) do
    [:tr,  
      Enum.map(me.header, fn h -> 
        cond do
          is_list(h) -> h
          Enum.any?(me.head_list, fn x -> x == h end) -> 
            [:td, me.css_th_left, h] 
          true -> [:td, me.css_th_right, h] 
        end
      end)
    ]
  end

  defp tbody(%@me{} = me) do
    css_m = Map.get(me, :css_map)

    body = 
      Enum.map(me.body, fn [k | tr] -> 
        css = Map.get(css_m, k, me.css_td)
        Enum.map(tr, fn td -> sz_td(me, td, css) end)
      end)


    body_keys = 
      Enum.map(me.body, fn [k | _tr] -> 
        k_list = Tuple.to_list(k)
        css = Map.get(css_m, k, :not_subtotal)
        Enum.map(k_list, fn td -> sz_td_left(me, td, css) end)
      end)

    Enum.zip(body_keys, body)
    |> Enum.map(fn {k, v} -> [:tr, me.css_tr, k ++ v] end)

  end

  defp tfoot(%@me{} = me) do
    [_h | row] = me.footer
    [:tr, 
      [[:td, %{class: "td-left td-foot sum-line font-bold"}, 
        "Total"] | Enum.map(row, fn r -> 
          sz_td(me, r, %{class: "td-right td-foot sum-line font-bold"}) 
      end)]
    ]
  end

  def as_sneeze(%@me{} = me) do
    [:table, 
      me.css_table, 
      thead(me),
      tbody(me),
      tfoot(me)
    ]
    |> Sneeze.render
  end

  defp sz_td(_me, %Decimal{}=td, map) when is_map(map) do
    [:td, map, fmt(:en, td, 2)]
  end
  defp sz_td(me, td, nil) do
    [:td, me.css_td, td]
  end
  defp sz_td(_me, td, map) when is_map(map) do
    [:td, map, td]
  end

  defp sz_td_left(me, td, :not_subtotal) do
    [:td, me.css_td_left, td]
  end
  defp sz_td_left(_me, td, _map) do
    [:td, %{class: "td-sub-total td-left"}, td]
  end

  def test do
    l = PiviEx.test2
    new(l, ["A"])
  end
end

