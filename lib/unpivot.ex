defmodule PiviEx.Unpivot do

#  @moduledoc """
#  Unpivot an csv file. 
#  """
#
#  def read_file(path) do
#    path
#    |> Path.expand(__DIR__)
#    |> File.stream!()
#    |> CSV.decode(separator: ?;, headers: false)
#    |> Enum.map(fn {:ok, r} -> r end)
#    #|> Stream.map(&String.split(&1, ";"))
#  end
#
#  def list_to_map(lst) do
#    [head | rest] = lst
#    Enum.map(rest, fn r -> 
#      Enum.zip(head, r) 
#    end)
#    |> Enum.map(fn r -> Enum.into(r, %{}) end)
#  end
#
#  #Enum.reduce(%{}, fn r, acc -> Map.put(acc, elem(r, 0), elem(r, 1)) end)
#
#  def path_export(file_name) do
#    "/mnt/c/Users/Alexander Hetland/Downloads/#{file_name}"
#  end
#
#  def test() do
#    path_export("export.csv")
#    |> read_file()
#    |> list_to_map()
#  end
#
#  def test_2() do
#    defs_to_atom |> defs_to_map
#  end
#
#  def repeated_lines() do
#    test_2()
#    |> Map.to_list()
#    |> Enum.map(fn r -> case r do
#      {p, {attr, val}} -> %{p => {attr, p}}
#        _ -> nil
#    end end)
#    |> Enum.filter(& &1)
#  end  
#
#  def header_lines() do
#    test_2()
#    |> Map.to_list()
#    |> Enum.map(fn r -> case r do
#      {p, {attr, val}} -> nil
#        _ -> r
#    end end)
#    |> Enum.filter(& &1)
#    |> Enum.into(%{})
#  end  
#
#
#  def test_3() do
#    xls_row = test() |> Enum.at(14)
#    IO.inspect repeated_lines()
#    header_lines() 
#  end
#
#  def test_4() do
#    for m <- repeated_lines() do
#      IO.puts "................."
#      p = Map.to_list(m) |> hd
#      IO.inspect p
#      for {k, v} = h <- header_lines() do
#        {k, v}
#      end
#    end
#  end
#
#  def test_5() do
#    for {k, v} <- header_lines(), m <- repeated_lines() do
#      IO.puts "................."
#      p = Map.to_list(m) |> hd
#        [p, {k, v}]
#    end
#  end
#
#  def test_6() do
#    Enum.map(repeated_lines, fn m -> 
#      Map.to_list(m)
#    end)
#    |> Enum.map(fn [{p, m}] -> m end)
#  end
#
#  def run() do
#    periods = test_6()
#    head = header_lines |> Map.to_list
#    test()
#    |> Enum.map(&repeat_records_by_value(&1, periods, head))
##    |> List.flatten()
#  end
#
#  def flatten_run_to_map(lst) do
#    Enum.map(lst, fn rp -> Enum.map(rp, fn r -> Enum.into(r, %{}) end) end)
#  end
#
#  def repeat_records_by_value() do
#    rec = Enum.at(test, 17)
#    repeat_records_by_value(rec)
#  end
#  def repeat_records_by_value(rec, periods, head) do
#    head_kw = Enum.map(head, fn {x,y} -> {y, Map.get(rec, x)} end)
#    
#    get_val = fn v -> Map.get(defs_to_map, v) |> elem(1) end
#
#    Enum.map(periods, fn p -> [p | head_kw] end)
#    |> Enum.map(fn [{s,h}=q | r] -> [q | [{get_val.(h), Map.get(rec, h)} | r]] end)
##    |> Enum.map(fn l -> Enum.into(l, %{}) end)
#  end
#
#  def repeat_records_by_value(rec) do
#    #rec = Enum.at(test, 17)
#    periods = test_6()
#    head = header_lines |> Map.to_list
#    repeat_records_by_value(rec, periods, head)
#  end
#
#  @doc """
#  Returning an atom indicates that the value is an attribute
#  and should be used as is.
#  Returning a tuple indicates that the value is a separate attribute
#  and that the value must be returned with a new key of that name.
#  """
#  def defs_to_map(lst) do
#    lst
#    |> Enum.into(%{}, fn [a,b,c] = r -> 
#                        case r do
#                          [a,b, nil] -> {a, b}
#                          [a, b, c] -> {a, {b,c}}
#                        end
#    end)
#  end
#  def defs_to_map() do
#    defs_to_atom |> defs_to_map()
#  end
#
#  def defs_to_atom() do
#    path_export("defs.csv")
#    |> read_file()
#    #remove empties
#    |> Enum.filter(fn [a, b, c] = r -> unless b=="", do: r end)
#    |> Enum.map(fn r -> r 
#                  case r do
#                    [a, b, ""] -> [a, b, nil]
#                    _ -> r
#                  end
#    end)
#    |> Enum.map(fn [a, b, c] -> [a, String.to_atom(b), c] end)
#    |> Enum.map(fn [a, b, c] -> [a, b, to_atom(c)] end)
#  end
#
#  defp to_atom(c) when is_binary(c) do
#    String.to_atom(c)
#  end
#  defp to_atom(c), do: nil


end

