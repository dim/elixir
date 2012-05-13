Code.require_file "../../test_helper", __FILE__

defmodule Binary.Inspect.AtomTest do
  use ExUnit.Case

  deftest :basic do
    assert inspect(:foo) == ":foo"
  end

  deftest :empty do
    assert inspect(:"") == ":\"\""
  end

  deftest :true_false_nil do
    assert inspect(false) == "false"
    assert inspect(true) == "true"
    assert inspect(nil) == "nil"
  end

  deftest :with_uppercase do
    assert inspect(:fOO) == ":fOO"
    assert inspect(:FOO) == ":FOO"
  end

  deftest :reference_atom do
    assert inspect(Foo.Bar) == "Foo.Bar"
  end

  deftest :impl do
    assert Binary.Inspect.Atom.__impl__ == Binary.Inspect
  end
end

defmodule Binary.Inspect.BitStringTest do
  use ExUnit.Case

  deftest :bitstring do
    assert inspect(<<1|12-:integer-:signed>>) == "<<0,1|4>>"
  end

  deftest :binary do
    assert inspect("foo") == "\"foo\""
    assert inspect(<<?a, ?b, ?c>>) == "\"abc\""
  end

  deftest :escape do
    assert inspect("f\no") == "\"f\\no\"" 
    assert inspect("f\\o") == "\"f\\\\o\""
  end

  deftest :utf8 do
    assert inspect(" ゆんゆん") == "\" ゆんゆん\""
  end

  deftest :unprintable do
    assert inspect(<<1>>) == "<<1>>"
  end
end

defmodule Binary.Inspect.NumberTest do
  use ExUnit.Case

  deftest :integer do
    assert inspect(100) == "100"
  end

  deftest :float do
    assert inspect(1.0) == "1.00000000000000000000e+00"
    assert inspect(1.0e10) == "1.00000000000000000000e+10"
    assert inspect(1.0e+10) == "1.00000000000000000000e+10"
  end
end

defmodule Binary.Inspect.TupleTest do
  use ExUnit.Case

  deftest :basic do
    assert inspect({ 1, "b", 3 }) == "{1,\"b\",3}"
  end

  deftest :record_like do
    assert inspect({ :foo, :bar }) == "{:foo,:bar}"
  end

  deftest :with_builtin_like_record do
    assert inspect({ :list, 1 }) == "{:list,1}"
  end

  deftest :with_record_like_tuple do
    assert inspect({ List, 1 }) == "{List,1}"
  end

  deftest :exception do
    assert inspect(RuntimeError.new) == "RuntimeError[message: \"runtime error\"]"
  end

  deftest :empty do
    assert inspect({}) == "{}"
  end
end

defmodule Binary.Inspect.ListTest do
  use ExUnit.Case

  deftest :basic do
    assert inspect([ 1, "b", 3 ]) == "[1,\"b\",3]"
  end

  deftest :printable do
    assert inspect('abc') == "'abc'"
  end

  deftest :non_printable do
    assert inspect([{:a,1}]) == "[{:a,1}]"
  end

  deftest :unproper do
    assert inspect([:foo | :bar]) == "[:foo|:bar]"
  end

  deftest :empty do
    assert inspect([]) == "[]"
  end
end

defmodule Binary.Inspect.AnyTest do
  use ExUnit.Case

  deftest :funs do
    bin = inspect(fn(x, do: x + 1))
    assert_match '#Fun<' ++ _, binary_to_list(bin)
  end
end

defmodule Binary.Inspect.RegexTest do
  use ExUnit.Case

  deftest :regex do
    "%r\"foo\"m" = inspect(%r(foo)m)
  end
end
