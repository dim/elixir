Code.require_file "../test_helper", __FILE__

defmodule CharListTest do
  use ExUnit.Case

  deftest :heredoc do
    assert __LINE__ == 7
    assert 'foo\nbar\n' == '''
foo
bar
'''

    assert __LINE__ == 13
    assert 'foo\nbar \'\'\'\n' == '''
foo
bar '''
'''
  end

  deftest :utf8 do
    assert length(' ゆんゆん') == 13
  end

  deftest :octals do
    assert '\123' == 'S'
    assert '\128' == '\n8'
    assert '\18' == [1, ?8]
  end

  deftest :__C__ do
    assert %C(foo) == 'foo'
    assert %C[foo] == 'foo'
    assert %C{foo} == 'foo'
    assert %C'foo' == 'foo'
    assert %C"foo" == 'foo'
    assert %C|foo| == 'foo'
    assert %C(f#{o}o) == 'f\#{o}o'
    assert %C(f\no) == 'f\\no'
  end

  deftest :__c__ do
    assert %c(foo) == 'foo'
    assert %c(f#{:o}o) == 'foo'
    assert %c(f\no) == 'f\no'
  end
end