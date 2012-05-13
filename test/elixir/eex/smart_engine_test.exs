Code.require_file "../../test_helper", __FILE__

defmodule EEx.SmartEngineTest do
  use ExUnit.Case

  deftest "evaluates simple string" do
    assert_eval "foo bar", "foo bar"
  end

  deftest "evaluates with assigns" do
    assert_eval "1", "<%= @foo %>", assigns: [foo: 1]
  end

  deftest "evaluates with loops" do
    assert_eval "1\n2\n3\n", "<%= for x in [1,2,3] do %><%= x %>\n<% end %>"
  end

  defp assert_eval(expected, actual, binding // []) do
    result = EEx.eval_string(actual, binding, file: __FILE__)
    assert result == expected
  end
end
