defmodule PiviEx.HtmlHelper do

  @doc """
  Convert a map into an href capable string by
  passing in a map of attributes and the href link
  """
  def convert_map_to_href_attr(m) when is_map(m) do
    m_as_list = Map.to_list(m) |> Enum.sort()

    lst = 
      m_as_list
      |> Enum.reduce([], fn {k, v}, acc -> 
        case v do
          nil -> ["&#{k}=nil" | acc] 
          _ -> ["&#{k}=#{v}" | acc] 
        end
      end)
      |> Enum.reverse()
      |> Enum.join()
                                                 
    replace_first_q(lst)
  end
  def convert_map_to_href_attr(m, path) when is_map(m) do
    path <> convert_map_to_href_attr(m)
  end

  defp replace_first_q("&" <> rest) do
    "?" <> rest
  end

end

