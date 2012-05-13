Code.require_file "../../test_helper", __FILE__

defmodule Kernel.DestructureTest do
  use ExUnit.Case

  deftest :less do
    destructure [x,y,z], [1,2,3,4,5]
    assert x == 1
    assert y == 2
    assert z == 3
  end

  deftest :more do
    destructure [a,b,c,d,e], [1,2,3]
    assert a == 1
    assert b == 2
    assert c == 3
    assert d == nil
    assert e == nil
  end

  deftest :equal do
    destructure [a,b,c], [1,2,3]
    assert a == 1
    assert b == 2
    assert c == 3
  end

  deftest :none do
    destructure [a,b,c], []
    assert a == nil
    assert b == nil
    assert c == nil
  end

  deftest :match do
    destructure [1,b,_], [1,2,3]
    assert b == 2
  end

  deftest :nil do
    destructure [a,b,c], a_nil
    assert a == nil
    assert b == nil
    assert c == nil
  end

  deftest :invalid_match do
    a = 3
    assert_raise CaseClauseError, fn ->
      destructure [^a,b,c], a_list
    end
  end

  defp a_list, do: [1,2,3]
  defp a_nil, do: nil
end
