Code.require_file "../test_helper", __FILE__

defmodule TupleTest do
  use ExUnit.Case

  deftest :elem do
    assert elem({ :a, :b, :c }, 2) == :b
  end

  deftest :setelem do
    assert setelem({ :a, :b, :c }, 2, :d) == { :a, :d, :c }
  end
end
