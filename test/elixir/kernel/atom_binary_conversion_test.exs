Code.require_file "../../test_helper", __FILE__

defmodule Kernel.AtomToBinaryTest do
  use ExUnit.Case

  deftest :atom_to_binary_defaults_to_utf8 do
    expected  = atom_to_binary :some_binary, :utf8
    actual    = atom_to_binary :some_binary

    assert actual == expected
    assert atom_to_binary(:another_atom) == "another_atom"
  end

  deftest :binary_to_atom_defaults_to_utf8 do
    expected  = binary_to_atom "some_binary", :utf8
    actual    = binary_to_atom "some_binary"

    assert actual == expected
    assert binary_to_atom("another_binary") == :another_binary
  end

  deftest :binary_to_existing_atom_defaults_to_utf8 do
    expected = binary_to_atom "existing_atom", :utf8
    actual   = binary_to_existing_atom "existing_atom"

    assert actual == expected

    :existing_atom
    assert binary_to_existing_atom("existing_atom") == :existing_atom

    assert_raise ArgumentError, fn ->
      binary_to_existing_atom "nonexisting_atom"
    end
  end
end
