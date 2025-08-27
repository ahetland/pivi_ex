defmodule PiviEx.Helper do

  def fmt(amount) do
    Number.Delimit.number_to_delimited(amount, precision: 2)
  end
  def fmt(:de, amount) do
    kw = [
      precision: 2,
      delimiter: ".",
      separator: ","
    ]
    Number.Delimit.number_to_delimited(amount, kw)
  end
  def fmt(amount, precision) do
    Number.Delimit.number_to_delimited(amount, precision: precision)
  end
  def fmt(:de, amount, precision) do
    kw = [
      precision: precision,
      delimiter: ".",
      separator: ","
    ]
    Number.Delimit.number_to_delimited(amount, kw)
  end
  def fmt(_format, amount, precision) do
    Number.Delimit.number_to_delimited(amount, precision: precision)
  end

  def fmk(%Decimal{} = amount, precision) do
    Decimal.div(amount, 1000)
    |> fmt(precision)
  end
  def fmk(:de, %Decimal{} = amount, precision) do
    a = Decimal.div(amount, 1000)
    fmt(:de, a, precision)
  end
  def fmk(_format, %Decimal{} = amount, precision) do
    fmk(amount, precision)
  end
  def fmb(%Decimal{} = amount, precision) do
    Number.Delimit.number_to_delimited(amount, precision: precision)
  end
  def fmb(amount, _precision), do: amount
end

