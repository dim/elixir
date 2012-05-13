Code.require_file "../../test_helper", __FILE__

defmodule Kernel.ImportOnlyTest do
  use ExUnit.Case

  import Erlang.lists, only: [flatten: 1]

  deftest :import_erlang do
    assert flatten([1,[2],3]) == [1,2,3]
  end
end

defmodule Kernel.ImportAllTest do
  use ExUnit.Case

  import Erlang.lists

  deftest :import_erlang do
    assert flatten([1,[2],3]) == [1,2,3]
  end
end

defmodule Kernel.ImportExceptTest do
  use ExUnit.Case

  import Erlang.lists, except: [each: 2]

  deftest :import_erlang do
    assert flatten([1,[2],3]) == [1,2,3]
  end
end

defmodule Kernel.ImportTwiceWithExceptTest do
  use ExUnit.Case

  import Erlang.lists, except: [flatten: 1]
  import Erlang.lists, except: [each: 2]

  deftest :import_erlang do
    assert flatten([1,[2],3]) == [1,[2],3]
  end

  def flatten(list), do: list
end

defmodule Kernel.MessedBitwise do
  defmacro bnot(x),   do: x
  defmacro bor(x, _), do: x
end

defmodule Kernel.ImportMacrosTest do
  use ExUnit.Case

  import :macros, Bitwise

  deftest :import_true do
    assert band(1, 1) == 1
    assert bor(0, 1) == 1
    assert bnot(0) == -1
  end

  deftest :function_import_with_only do
    import :macros, Bitwise, except: [bnot: 1]
    import :macros, Kernel.MessedBitwise, only: [bnot: 1]
    assert bnot(0) == 0
    assert bor(0, 1) == 1
  end

  # This test is asserting that the requires done
  # inside the function do not affect outer ones.
  deftest :import_true_not_affected do
    assert band(1, 1) == 1
    assert bor(0, 1) == 1
    assert bnot(0) == -1
  end
end
