defmodule PiviEx.Search do

  def contains?(a, b) do
    String.downcase(a || "")
    |> String.contains?(String.downcase(b))
  end

  defp searchrecur(search_lst, [], _f) do
    search_lst
  end
  defp searchrecur(search_lst, [str_in_lst | rest], f) do
    search_match(search_lst, str_in_lst, f)
    |> searchrecur(rest, f)
  end
  defp search_match(search_lst, str, f) do
    Enum.filter(search_lst, fn r -> f.(r, str) end)
  end

  defp search_or(search_lst, str, f) do
    Enum.filter(search_lst, fn r -> f.(r, str) end)
  end

  def search(lst, str, record_matches) do
    case String.contains?(str, "||") do
      true -> [a, b] = String.split(str, "||")
              search_or(lst, a, record_matches) 
              ++ search_or(lst, b, record_matches) 
      _ -> a = String.split(str, "+")
           searchrecur(lst, a, record_matches)
    end
  end

end

