Code.require_file "../test_helper", __FILE__

defmodule MacroTest do
  use ExUnit.Case

  deftest :escapes_tuples_with_size_different_than_two do
    assert { :{}, 0, [:a] } == Macro.escape({ :a })
    assert { :{}, 0, [:a, :b, :c] } == Macro.escape({ :a, :b, :c })
  end

  deftest :simply_returns_macros_with_size_equal_to_two do
    assert { :a, :b } == Macro.escape({ :a, :b })
  end

  deftest :returns_any_other_structure do
    assert [1,2,3] == Macro.escape([1,2,3])
  end

  deftest :works_recursively do
    assert [1,{:{}, 0, [:a,:b,:c]},3] == Macro.escape([1, { :a, :b, :c },3])
  end
end