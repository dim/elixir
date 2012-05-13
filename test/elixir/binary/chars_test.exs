Code.require_file "../../test_helper", __FILE__

defmodule Binary.Chars.AtomTest do
  use ExUnit.Case

  test :basic, do:
    assert to_binary(:foo) == "foo"
  end

  test :empty, do:
    assert to_binary(:"") == ""
  end

  test :true_false_nil, do:
    assert to_binary(false) == "false"
    assert to_binary(true) == "true"
    assert to_binary(nil) == ""
  end

  test :with_uppercase, do:
    assert to_binary(:fOO) == "fOO"
    assert to_binary(:FOO) == "FOO"
  end

  test :reference_atom, do:
    assert to_binary(Foo.Bar) == "__MAIN__.Foo.Bar"
  end
end

defmodule Binary.Chars.BitStringTest do
  use ExUnit.Case

  test :bitstring, do:
    assert_raise FunctionClauseError, fn ->
      to_binary(<<1|12-:integer-:signed>>)
    end
  end

  test :binary, do:
    assert to_binary("foo") == "foo"
    assert to_binary(<<?a, ?b, ?c>>) == "abc"
    assert to_binary("我今天要学习.") == "我今天要学习."
  end
end

defmodule Binary.Chars.NumberTest do
  use ExUnit.Case

  test :integer, do:
    assert to_binary(100) == "100"
  end

  test :float, do:
    assert to_binary(1.0) == "1.00000000000000000000e+00"
    assert to_binary(1.0e10) == "1.00000000000000000000e+10"
    assert to_binary(1.0e+10) == "1.00000000000000000000e+10"
  end
end

defmodule Binary.Chars.ListTest do
  use ExUnit.Case

  test :basic, do:
    assert to_binary([ 1, "b", 3 ]) == <<1,98,3>>
  end

  test :printable, do:
    assert to_binary('abc') == "abc"
  end

  test :empty, do:
    assert to_binary([]) == ""
  end
end
