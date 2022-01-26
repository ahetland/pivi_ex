defmodule PiviEx.File do

  @moduledoc """
  Utilities for files
  """

  def md5sum(file) do
    {:ok, content} = File.read file
    :crypto.hash(:md5, content) |> Base.encode16
  end

  @doc """
  Hasing a file.

  Taken from: https://www.poeticoding.com/hashing-a-file-in-elixir/
  """
  def sha256sum(file) do
    File.stream!(file)
    |> Enum.reduce(:crypto.hash_init(:sha256),&(:crypto.hash_update(&2, &1)))
    |> :crypto.hash_final()
    |> Base.encode16()
    |> String.downcase()
  end

end

