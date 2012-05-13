defmodule IO do
  @moduledoc """
  Module responsible for doing IO.
  It is incomplete now. More functions will be
  added in upcoming releases.
  """

  @doc """
  Prints the given argument to the given device.
  By default the device is the standard output.
  The argument is converted to binary before
  printing.

  It returns `:ok` if it succeeds.

  ## Examples

      IO.print :sample
      #=> "sample"

      IO.print :standard_error, "error"
      #=> "error"

  """
  def print(device // :standard_io, item) do
    Erlang.io.put_chars device, to_binary(item)
  end

  @doc """
  Prints the given argument to the device,
  similarly to print but adds a new line
  at the end.
  """
  def puts(device // :standard_io, item) do
    Erlang.io.put_chars device, to_binary(item)
    Erlang.io.nl(device)
  end

  @doc """
  Prints the given argument to the device
  but inspects it before.
  """
  def inspect(device // :standard_io, item) do
    puts device, Elixir.Builtin.inspect(item)
  end
end