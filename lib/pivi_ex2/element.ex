defmodule PiviEx2.Element do

  @me __MODULE__

  defstruct row: nil, col: nil, amount: Decimal.new(0)

  def new(), do: %@me{}

  def append(%@me{} = me, row) do
    %{me | row: row}
  end

end

