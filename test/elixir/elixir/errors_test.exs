Code.require_file "../../test_helper", __FILE__

defmodule Elixir.ErrorsTest do
  use ExUnit.Case

  defmodule UnproperMacro do
    defmacro unproper(args), do: args
    defmacro exit(args), do: args
  end

  defrecord Config, integer: 0

  deftest :invalid_token do
    assert "nofile:1: invalid token: \end" == format_rescue '\end'
  end

  deftest :invalid_partial do
    assert "nofile:1: partial variable &2 cannot be defined without &1" == format_rescue '&2 + 3'
  end

  deftest :syntax_error do
    assert "nofile:1: syntax error before: '}'" == format_rescue 'case 1 do }'
  end

  deftest :syntax_error_with_no_token do
    assert "nofile:1: syntax error: expression is incomplete" == format_rescue 'case 1 do'
  end

  deftest :bad_form do
    assert "nofile:2: function bar/0 undefined" == format_rescue 'defmodule Foo do\ndef foo, do: bar\nend'
  end

  deftest :unbound_var do
    assert "nofile:1: unbound variable ^x" == format_rescue('^x = 1')
  end

  deftest :unbound_not_assignment do
    assert "nofile:1: cannot access variable ^x outside of assignment" == format_rescue('^x')
  end

  deftest :unbound_expr do
    assert "nofile:1: cannot use ^ with expression at ^x, ^ must be used only with variables" == format_rescue('^x(1)')
  end

  deftest :name_for_defmodule do
    assert "nofile:1: invalid module name: 3" == format_rescue 'defmodule 1 + 2, do: 3'
  end

  deftest :invalid_scope_for_function do
    assert "nofile:1: cannot invoke def outside module" == format_rescue 'def Foo, do: 2'
    assert "nofile:3: cannot invoke defmacro outside module" == format_rescue '\n\ndefmacro Foo, do: 2'
  end

  deftest :invalid_quote_args do
    assert "nofile:1: invalid args for quote" == format_rescue 'quote 1'
  end

  deftest :invalid_fn_args do
    assert "nofile:1: no block given to fn" == format_rescue 'fn 1'
  end

  deftest :unproper_macro do
    assert "nofile:4: keywords block not supported by Elixir.ErrorsTest.UnproperMacro.unproper/1" ==
      format_rescue 'defmodule Foo do\nrequire Elixir.ErrorsTest.UnproperMacro\nElixir.ErrorsTest.UnproperMacro.unproper do\nmatch: 1\n2\nmatch: 3\nend\nend'
  end

  deftest :macro_conflict do
    assert "nofile:1: imported Elixir.Builtin.defrecord/2 conflicts with local function" ==
      format_rescue 'defmodule Foo do\ndefrecord(Elixir.ErrorsTest.MacroConflict, a: 1)\ndef defrecord(_, _), do: OMG\nend'
  end

  deftest :macro_with_undefined_local do
    assert "undefined function: Foo.unknown/1" ==
      format_rescue 'defmodule Foo do\ndefmacrop bar, do: unknown(1)\ndef baz, do: bar()\nend'
  end

  deftest :private_macro do
    assert "undefined function: Foo.foo/0" ==
      format_rescue 'defmodule Foo do\ndefmacrop foo, do: 1\ndefmacro bar, do: __MODULE__.foo\ndefmacro baz, do: bar\nend'
  end

  deftest :erlang_function_conflict do
    assert "nofile:1: function exit/1 already imported from Elixir.Builtin" ==
      format_rescue 'defmodule Foo do import Elixir.ErrorsTest.UnproperMacro, only: [exit: 1]\nend'
  end

  deftest :import_invalid_macro do
    assert "nofile:2: cannot import Elixir.Builtin.invalid/1 because it doesn't exist" ==
      format_rescue 'defmodule Foo do\nimport Elixir.Builtin, only: [invalid: 1]\nend'
  end

  deftest :unrequired_macro do
    assert "nofile:2: tried to invoke macro Elixir.ErrorsTest.UnproperMacro.unproper/1 but module was not required. Required: ['Elixir.Builtin']" ==
      format_rescue 'defmodule Foo do\nElixir.ErrorsTest.UnproperMacro.unproper([])\nend'
  end

  deftest :def_defmacro_clause_change do
    assert "nofile:3: defmacro foo/1 already defined as def" ==
      format_rescue 'defmodule Foo do\ndef foo(1), do: 1\ndefmacro foo(x), do: x\nend'
  end

  deftest :clause_change do
    assert "nofile:4: function foo/1 does not match previous clause bar/1" ==
      format_rescue 'defmodule Foo do\ndef foo(1), do: 1\ndef bar(x), do: x\ndef foo(x), do: x\nend'
  end

  deftest :internal_function_overriden do
    assert "nofile:1: function __info__/1 is internal and should not be overriden" ==
      format_rescue 'defmodule Foo do\ndef __info__(_), do: []\nend'
  end

  deftest :no_macros do
    assert "nofile:2: could not load macros from module lists" ==
      format_rescue 'defmodule Foo do\nimport :macros, Erlang.lists\nend'
  end

  deftest :unloaded_module do
    assert "nofile:1: module Certainly.Doesnt.Exist is not loaded and could not be found" ==
      format_rescue 'import Certainly.Doesnt.Exist'
  end

  deftest :scheduled_module do
    assert "nofile:1: module Foo.Hygiene is not loaded but was defined. This happens because you are trying to use a module in the same context it is defined. Try defining the module outside the context that requires it." ==
      format_rescue 'defmodule Foo do; defmodule Hygiene do; end; import Foo.Hygiene; end'
  end

  deftest :already_compiled_module do
    assert "could not call eval_quoted on module Record because it was already compiled" ==
      format_rescue 'Module.eval_quoted Record, quote(do: 1), [], file: __FILE__, line: __LINE__'
  end

  deftest :interpolation_error do
    assert "nofile:1: syntax error before: ')'" == format_rescue '"foo\#{case 1 do )}bar"'
  end

  deftest :invalid_kv_for_match do
    assert "nofile:1: invalid key invalid" ==
      format_rescue 'case true do\ninvalid: 2\nafter: 3\nend'
  end

  deftest :cant_define_local_due_to_in_erlang_macros_conflict do
    assert "nofile:1: cannot define local quote/1 because it conflicts with Elixir internal macros" ==
      format_rescue 'defmodule Foo do\ndef quote(x), do: x\ndef bar(x), do: quote(do: x)\nend'
  end

  deftest :already_defined_module do
    assert "nofile:1: module Record already defined (please ensure remove compiled files before recompiling a module)" ==
      format_rescue 'defmodule Record, do: true'
  end

  deftest :duplicated_bitstring_size do
    assert "nofile:1: duplicated size specifier 12 in <<>>" == format_rescue '<<1|12-12>>'
  end

  deftest :invalid_bitstring_specified do
    assert "nofile:1: invalid specifier for <<>>" == format_rescue '<<1|12-binary()>>'
  end

  deftest :invalid_access_protocol_not_reference do
    assert "nofile:2: invalid usage of access protocol in signature" ==
      format_rescue 'defmodule Foo do\ndef sample(config[integer: 0]), do: true\nend'
  end

  deftest :invalid_access_protocol_not_available do
    assert "nofile:2: module Unknown is not loaded and could not be found" ==
      format_rescue 'defmodule Foo do\ndef sample(Unknown[integer: 0]), do: true\nend'
  end

  deftest :invalid_access_protocol_not_record do
    assert "nofile:2: cannot use module Elixir.ErrorsTest in access protocol because it doesn't represent a record" ==
      format_rescue 'defmodule Foo do\ndef sample(Elixir.ErrorsTest[integer: 0]), do: true\nend'
  end

  deftest :invalid_access_protocol_not_keywords do
    assert "nofile:2: expected contents inside brackets to be a Keyword" ==
      format_rescue 'defmodule Foo do\ndef sample(Elixir.ErrorsTest.Config[0]), do: true\nend'
  end

  deftest :invalid_access_protocol_invalid_keywords do
    assert "nofile:2: record Elixir.ErrorsTest.Config does not have some of the given keys: [foo]" ==
      format_rescue 'defmodule Foo do\ndef sample(Elixir.ErrorsTest.Config[foo: :bar]), do: true\nend'
  end

  deftest :invalid_access_protocol_invalid_keywords_outside_assignment do
    assert "nofile:1: record Elixir.ErrorsTest.Config does not have some of the given keys: [foo]" ==
      format_rescue 'Elixir.ErrorsTest.Config[foo: :bar]'
  end

  deftest :invalid_access_protocol_on_rescue do
    assert "nofile:1: cannot (yet) pattern match against erlang exceptions" ==
      format_rescue 'try do\n1\nrescue:\nUndefinedFunctionError[arity: 1] -> false\nend'
  end

  deftest :invalid_bc do
    assert "nofile:1: a bit comprehension expects a bit string << >> to be returned" ==
      format_rescue 'bc x in [1,2,3], do: x'
  end

  ## Helpers

  defp format_rescue(expr) do
    result = try do:
      Erlang.elixir.eval(expr, [])
      nil
    rescue:
      error -> error.message
    end

    result || raise(ExUnit.AssertionError, message: "Expected function given to format_rescue to fail")
  end
end
