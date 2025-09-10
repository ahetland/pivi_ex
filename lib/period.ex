defmodule PiviEx.Period do
  @moduledoc """
  Helper to create a period from an integer.
  """

  ## NaiveDates

  def naive_date(day) do
    {:ok, date} = NaiveDateTime.from_iso8601 "#{day} 00:00:00"
    date
  end

  def period(%NaiveDateTime{} = date) do
    parse_naive(date)
    |> period
  end

  def period(%Date{} = date) do
    date.year * 100 + date.month
  end

  def period_dates(str) when is_binary(str) do
    period_dates(String.to_integer(str))
  end

  def period_dates(int) when int > 190_000 do
    year = div(int, 100)
    month = rem(int, 100)
    {:ok, first_date} = Date.new(year, month, 1)
    {:ok, last_date} = Date.new(year, month, Date.days_in_month(first_date))
    {:ok, first_date, last_date}
  end
  
  def period_dates(int) when int > 1900 and int < 2030 do
    {:ok, first_date} = Date.new(int, 1, 1)
    {:ok, last_date} = Date.new(int, 12, 31)
    {:ok, first_date, last_date}
  end

  @doc """
  Given a year in int returns the first month and last month 
  for that year.

  Example year_firstmonth_lastmonth(2023)
  >> {202301, 202312}
  """
  def year_firstmonth_lastmonth(year) when is_integer(year) do
    {year * 100 + 1, year * 100 + 12}
  end

  def zero_month_of_period(period) when is_binary(period) do
    String.to_integer(period)
    |> zero_month_of_period()
  end
  def zero_month_of_period(period) when is_integer(period) do
    year = div(period, 100)
    year * 100
  end

  @doc """
  Returns the range of periods in a year.
  """
  def year_range(year) when is_integer(year) do
    year * 100 + 1..year * 100 + 12 
  end

  def last_years_period(period) when is_integer(period) do
    cond do
      period > 190100 ->
        year = div(period, 100)
        month = rem(period, 100)
        (year - 1) * 100 + month
      period < 9999 -> period - 1
    end
  end

  def period_valid?(period) do
    year = div(period, 100)
    month = rem(period, 100)
    cond do
      year < 1999 || year > 2099 -> false
      month < 0 || month > 12 -> false
      true -> true
    end
  end

  @doc """
  From an integer in format yyyymmdd returns the date.
  """
  def date_from_int(date_int) when is_integer(date_int) do
    day = rem(date_int, 100)
    year = div(date_int, 10000)
    period = div(date_int, 100)
    month = rem(period, 100)
    Date.new(year, month, day)
  end
  def date_from_int(date_int) when is_binary(date_int) do
    {d, _} = Integer.parse(date_int)
    date_from_int(d)
  end

  @doc """
  Takes a German date format with a dot. e.g. 24.12.2019 Happy X-Mas
  """
  def from_string(:d_m_y, str) when is_binary(str) do
    case String.split(str, ".") do
      [d, m, y] -> from_string(:d_m_y, d, m, y)
      _ -> :error
    end
  end

  def from_string(:d_m_y, _anything) do
    false
  end

  def from_string(:d_m_y, d, m, y) do
    [{d, _}, {m, _}, {y, _}] = [Integer.parse(d), Integer.parse(m), Integer.parse(y)]
    Date.new(y, m, d)
  end

  def from_string(:m_d_y, m, d, y) do
    [{d, _}, {m, _}, {y, _}] = [Integer.parse(d), Integer.parse(m), Integer.parse(y)]
    Date.new(y, m, d)
  end

  def to_iso_8859_str(%Date{} = date) do
    [y, m, d] = Date.to_string(date) |> String.split("-")
    d <> "." <> m <> "." <> y 
  end

  def to_integer({:ok, first_date, last_date}) do
    first_date = Date.to_string(first_date) |> String.replace("-", "") |> String.to_integer()
    last_date = Date.to_string(last_date) |> String.replace("-", "") |> String.to_integer()
    {:ok, first_date, last_date}
  end

  def to_string({:ok, first_date, last_date}) do
    first_date = Date.to_string(first_date)
    last_date = Date.to_string(last_date)
    {:ok, first_date, last_date}
  end

  @doc """
  Returns date_from and date_to from a string or integer.
  """
  def date_to_from(str) when is_binary(str) do
    cond do
      String.contains?(str, "..") ->
        [from, to] = String.split(str, "..")
        {date_to_from(from), date_to_from(to)}

      Regex.match?(~r/^\d{1,2}\.\d{1,2}\.\d{4}$/, str) ->
        [d, m, y] = String.split(str, ".")
        Date.new(String.to_integer(y), String.to_integer(m), String.to_integer(d))

      Regex.match?(~r/^\d{1,2}\.\d{1,2}\.\d{1,2}$/, str) ->
        [d, m, y] = String.split(str, ".")
        Date.new(String.to_integer(y) + 2000, String.to_integer(m), String.to_integer(d))

      Regex.match?(~r/^\d{4}-\d{1,2}-\d{1,2}$/, str) ->
        [y, m, d] = String.split(str, "-")
        Date.new(String.to_integer(y), String.to_integer(m), String.to_integer(d))

      Regex.match?(~r/^\d{2}-\d{1,2}-\d{1,2}$/, str) ->
        [y, m, d] = String.split(str, "-")
        Date.new(String.to_integer(y) + 2000, String.to_integer(m), String.to_integer(d))

      true ->
        String.to_integer(str) |> date_to_from()
    end
  end

  def date_to_from(int) when is_integer(int) do
    case length(Integer.digits(int)) do
      4 ->
        period_dates(int)
      6 ->
        period_dates(int)
      8 ->
        date_from_int(int)
      _ ->
        {:error, :invalid_date}
    end
  end

  def name(%Date{} = date) do
    {y, m, _d} = Date.to_erl(date)
    period = (y * 100) + m
    name(period)
  end

  def name(str) when is_binary(str) do
    [y, m, _d] = String.split(str, "-")
    p = y <> m
    name(String.to_integer(p))
  end

  #def name(:de, period) when period > 190_000 and period < 205_000 do
  def name(:de, period) do
    year = div(period, 100)
    month = rem(period, 100)

    case month do
      1 -> "Jan-#{year}"
      2 -> "Feb-#{year}"
      3 -> "Mrz-#{year}"
      4 -> "Apr-#{year}"
      5 -> "Mai-#{year}"
      6 -> "Jun-#{year}"
      7 -> "Jul-#{year}"
      8 -> "Aug-#{year}"
      9 -> "Sep-#{year}"
      10 -> "Okt-#{year}"
      11 -> "Nov-#{year}"
      12 -> "Dez-#{year}"
      _ -> :error
    end
  end

  def name(:us, period) when period > 190_000 and period < 205_000 do
    year = div(period, 100)
    month = rem(period, 100)

    case month do
      1 -> "January #{year}"
      2 -> "February #{year}"
      3 -> "March #{year}"
      4 -> "April #{year}"
      5 -> "May #{year}"
      6 -> "June #{year}"
      7 -> "July #{year}"
      8 -> "August #{year}"
      9 -> "September #{year}"
      10 -> "October #{year}"
      11 -> "November #{year}"
      12 -> "December #{year}"
      _ -> :error
    end
  end

  def yield_periods(start_period, end_period) do
    raise("crap")
    start_year = div(start_period, 100)
    start_month = rem(start_period, 100)
    start_year_dec = start_year * 100 + 12

    end_year = div(end_period, 100)
    end_month = rem(end_period, 100)
    end_year_jan = end_year * 100 + 1

    cond do
      end_month > 12 -> raise {:error, "End month error."}
      start_month > 12 -> raise {:error, "Start month error."}
      end_year - start_year > 1 -> raise {:error, "Helper only implemented for two years ..."}
      end_year - start_year < 1 -> raise {:error, "Helper only implemented for two years ..."}
      true -> :ok
    end

    Enum.map(start_period..start_year_dec, & &1) ++ Enum.map(end_year_jan..end_period, & &1)
  end

  def from_quarter(quarter) when is_integer(quarter), do: quarter
  def from_quarter(quarter) when is_binary(quarter) do
    if String.contains?(quarter, "-") do
      [year, quarter] = String.split(quarter, "-")

      {year, quarter} = 
        if String.contains?(year, "Q") do
          {String.to_integer(quarter) * 100, year}
        else
          {String.to_integer(year) * 100, quarter}
        end

      cond do
        quarter=="Q1" -> {:ok, (year + 1)..(year + 3)}
        quarter=="Q2" -> {:ok, (year + 4)..(year + 6)}
        quarter=="Q3" -> {:ok, (year + 7)..(year + 9)}
        quarter=="Q4" -> {:ok, (year + 10)..(year + 12)}
        true -> {:error, quarter}
      end
    else
        {:error, quarter}
    end
  end

  def to_quarter(period) when is_integer(period) do
    y = div(period, 100)
    m = rem(period, 100)

    cond do 
      m in 1..3 -> "#{y}-Q1"
      m in 4..6 -> "#{y}-Q2"
      m in 7..9 -> "#{y}-Q3"
      m in 10..12 -> "#{y}-Q4"
      true -> raise("Error in period calculation for quarter")
    end
  end

  def parse_naive(nil), do: nil
  def parse_naive(dt) do
    NaiveDateTime.to_date(dt)
  end

end
