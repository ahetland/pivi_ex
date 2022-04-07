ExUnit.start
#Code.require_file("html_helper.ex", __DIR__)

defmodule PiviEx.HtmlHelperTest do

  use ExUnit.Case
  alias PiviEx.HtmlHelper

  test "is the file loaded" do
    assert Code.ensure_loaded?(PiviEx.HtmlHelper)
  end

  test "can convert map to href parts" do
    m = %{comment: "a comment",
          report: "F03"}
    assert HtmlHelper.convert_map_to_href_attr(m) 
            ==  "?comment=a comment&report=F03"
  end

  test "when nil is passed adds a nil string" do
    assert HtmlHelper.convert_map_to_href_attr(%{empty: nil, not_empty: "ok"})
          == "?empty=nil&not_empty=ok"
  end

end


