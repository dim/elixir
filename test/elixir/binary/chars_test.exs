Code.require_file "../../test_helper", __FILE__

defmodule Binary.Chars.AtomTest do
  use ExUnit.Case

  deftest :basic do
    assert to_binary(:foo) == "foo"
  end

  deftest :empty do
    assert to_binary(:"") == ""
  end

  deftest :true_false_nil do
    assert to_binary(false) == "false"
    assert to_binary(true) == "true"
    assert to_binary(nil) == ""
  end

  deftest :with_uppercase do
    assert to_binary(:fOO) == "fOO"
    assert to_binary(:FOO) == "FOO"
  end

  deftest :reference_atom do
    assert to_binary(Foo.Bar) == "__MAIN__.Foo.Bar"
  end
end

defmodule Binary.Chars.BitStringTest do
  use ExUnit.Case

  deftest :bitstring do
    assert_raise FunctionClauseError, fn ->
      to_binary(<<1|12-:integer-:signed>>)
    end
  end

  deftest :binary do
    assert to_binary("foo") == "foo"
    assert to_binary(<<?a, ?b, ?c>>) == "abc"
    assert to_binary("我今天要学习.") == "我今天要学习."
  end
end

defmodule Binary.Chars.NumberTest do
  use ExUnit.Case

  deftest :integer do
    assert to_binary(100) == "100"
  end

  deftest :float do
    assert to_binary(1.0) == "1.00000000000000000000e+00"
    assert to_binary(1.0e10) == "1.00000000000000000000e+10"
    assert to_binary(1.0e+10) == "1.00000000000000000000e+10"
  end
end

defmodule Binary.Chars.ListTest do
  use ExUnit.Case

  deftest :basic do
    assert to_binary([ 1, "b", 3 ]) == <<1,98,3>>
  end

  deftest :printable do
    assert to_binary('abc') == "abc"
  end

  deftest :empty do
    assert to_binary([]) == ""
  end
end
