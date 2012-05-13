Code.require_file "../test_helper", __FILE__

defmodule BinaryTest do
  use ExUnit.Case

  deftest :heredoc do
    assert 7 == __LINE__
    assert "foo\nbar\n" == """
foo
bar
"""

    assert 13 == __LINE__
    assert "foo\nbar \"\"\"\n" == """
foo
bar """
"""
  end

  deftest :heredoc_with_extra do
    assert 21 == __LINE__
    assert "foo\nbar\nbar\n" == """ <> "bar\n"
foo
bar
"""
  end

  deftest :aligned_heredoc do
    assert "foo\nbar\nbar\n" == """ <> "bar\n"
    foo
    bar
    """
  end

  deftest :utf8 do
    assert size(" ゆんゆん") == 13
  end

  deftest :utf8_char do
    assert ?ゆ == 12422
    assert ?\ゆ == 12422
  end

  deftest :string_concatenation_as_match do
    "foo" <> x = "foobar"
    assert x == "bar"
  end

  deftest :__B__ do
    assert %B(foo) == "foo"
    assert %B[foo] == "foo"
    assert %B{foo} == "foo"
    assert %B'foo' == "foo"
    assert %B"foo" == "foo"
    assert %B|foo| == "foo"
    assert %B(f#{o}o) == "f\#{o}o"
    assert %B(f\no) == "f\\no"
  end

  deftest :__b__ do
    assert %b(foo) == "foo"
    assert %b(f#{:o}o) == "foo"
    assert %b(f\no) == "f\no"
  end

  deftest :__B__with_heredoc do
    assert "  f\#{o}o\\n\n" == %B"""
      f#{o}o\n
    """
  end

  deftest :__b__with_heredoc do
    assert "  foo\n\n" == %b"""
      f#{:o}o\n
    """
  end

  deftest :octals do
    assert "\123" == "S"
    assert "\128" == "\n8"
    assert "\18"  == <<1,?8>>
  end

  deftest :match do
    assert is_match?("ab", ?a)
    assert not is_match?("cd", ?a)
  end

  deftest :pattern_match do
    s = 16
    assert_match <<a, b|s>>, "foo"
  end

  defp is_match?(<<char, _|:binary>>, char) do
    true
  end

  defp is_match?(_, _) do
    false
  end
end