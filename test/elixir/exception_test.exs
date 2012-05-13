Code.require_file "../test_helper", __FILE__

defmodule Kernel.ExceptionTest do
  use ExUnit.Case

  deftest :is_exception do
    assert is_exception(RuntimeError.new)
    refute is_exception({ :foo, :bar })
  end

  deftest :format_stacktrace_with_no_file_or_line do
    assert Exception.format_stacktrace({Foo, :bar, [1, 2, 3], []}) == "Foo.bar(1, 2, 3)"
    assert Exception.format_stacktrace({Foo, :bar, [], []}) == "Foo.bar()"
    assert Exception.format_stacktrace({Foo, :bar, 1, []}) == "Foo.bar/1"
  end

  deftest :format_stacktrace_with_file_and_line do
    assert Exception.format_stacktrace({Foo, :bar, [], [file: 'file.ex', line: 10]}) == "file.ex:10: Foo.bar()"
    assert Exception.format_stacktrace({Foo, :bar, [1, 2, 3], [file: 'file.ex', line: 10]}) == "file.ex:10: Foo.bar(1, 2, 3)"
    assert Exception.format_stacktrace({Foo, :bar, 1, [file: 'file.ex', line: 10]}) == "file.ex:10: Foo.bar/1"
  end

  deftest :format_stacktrace_with_file_no_line do
    assert Exception.format_stacktrace({Foo, :bar, [], [file: 'file.ex']}) == "file.ex: Foo.bar()"
    assert Exception.format_stacktrace({Foo, :bar, [], [file: 'file.ex', line: 0]}) == "file.ex: Foo.bar()"
    assert Exception.format_stacktrace({Foo, :bar, [1, 2, 3], [file: 'file.ex']}) == "file.ex: Foo.bar(1, 2, 3)"
    assert Exception.format_stacktrace({Foo, :bar, 1, [file: 'file.ex']}) == "file.ex: Foo.bar/1"
  end

  deftest :format_module_function_arity do
    assert Exception.format_module_fun_arity Foo, :bar, 1 == "Foo.bar/1"
    assert Exception.format_module_fun_arity Foo, :bar, [] == "Foo.bar()"
    assert Exception.format_module_fun_arity :foo,  :bar, [1,2] == ":foo.bar(1, 2)"
  end

  deftest :format_module_function_arity_with_special_function_name do
    assert Exception.format_module_fun_arity Foo, :"bar baz", 1 == "Foo.\"bar baz\"/1"
  end

  deftest :runtime_error_message do
    assert RuntimeError.new.message == "runtime error"
    assert RuntimeError.new(message: "exception").message == "exception"
  end

  deftest :argument_error_message do
    assert ArgumentError.new.message == "argument error"
    assert ArgumentError.new(message: "exception").message == "exception"
  end

  deftest :undefined_function_message do
    assert UndefinedFunctionError.new.message == "undefined function"
    assert UndefinedFunctionError.new(module: Foo, function: :bar, arity: 1).message == "undefined function: Foo.bar/1"
    assert UndefinedFunctionError.new(module: Foo, function: :bar, arity: []).message == "undefined function: Foo.bar/0"
    assert UndefinedFunctionError.new(module: :foo,  function: :bar, arity: []).message == "undefined function: :foo.bar/0"
  end

  deftest :function_clause_message do
    assert FunctionClauseError.new.message == "no function clause matches"
    assert FunctionClauseError.new(module: Foo, function: :bar, arity: 1).message == "no function clause matching: Foo.bar/1"
    assert FunctionClauseError.new(module: Foo, function: :bar, arity: []).message == "no function clause matching: Foo.bar()"
    assert FunctionClauseError.new(module: :foo,  function: :bar, arity: []).message == "no function clause matching: :foo.bar()"
  end

  deftest :erlang_error_message do
    assert ErlangError.new(original: :sample).message == "erlang error: :sample"
  end
end