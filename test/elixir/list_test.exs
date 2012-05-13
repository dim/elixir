Code.require_file "../test_helper", __FILE__

defmodule ListTest do
  use ExUnit.Case

  deftest :brackets_function do
    assert :[].(1,2,3) == [1,2,3]
  end

  deftest :wrap do
    assert List.wrap([1,2,3]) == [1,2,3]
    assert List.wrap(1) == [1]
    assert List.wrap(nil) == []
  end

  deftest :flatten do
    assert List.flatten([1,2,3]) == [1,2,3]
    assert List.flatten([1,[2],3]) == [1,2,3]
    assert List.flatten([[1,[2],3]]) == [1,2,3]

    assert List.flatten([]) == []
    assert List.flatten([[]]) == []
  end

  deftest :flatten_with_tail do
    assert List.flatten([1,2,3], [4,5]) == [1,2,3,4,5]
    assert List.flatten([1,[2],3], [4,5]) == [1,2,3,4,5]
    assert List.flatten([[1,[2],3]], [4,5]) == [1,2,3,4,5]
  end

  deftest :foldl do
    assert List.foldl([1,2,3], 0, fn x,y -> x + y end) == 6
    assert List.foldl([1,2,3], 10, fn x,y -> x + y end) == 16
    assert List.foldl([1,2,3,4], 0, fn x,y -> x - y end) == 2
  end

  deftest :foldr do
    assert List.foldr([1,2,3], 0, fn x,y -> x + y end) == 6
    assert List.foldr([1,2,3], 10, fn x,y -> x + y end) == 16
    assert List.foldr([1,2,3,4], 0, fn x,y -> x - y end) == -2
  end

  def test_member? do
    assert List.member? [1,2,3], 1
    refute List.member? [1,2,3], 0
    refute List.member? [], 0
  end

  deftest :range do
    assert List.range(1,3) == [1,2,3]
    assert List.range(1, 1) == [1]
    assert List.range(5, 0) == [5,4,3,2,1,0]
    assert List.range(1, 0, -1) == [1,0]
    assert List.range(1,8,2) == [1,3,5,7]
    assert List.range(7,-1,-3) == [7,4,1]
    assert List.range(2,1,1) == []
    assert List.range(8,1,1) == []
    assert List.range(1,8,-1) == []
    assert List.range(1,1,-1) == []
  end

  deftest :sort do
    assert List.sort([3, 5, 1, 2, 4]) == [1,2,3,4,5]
    assert List.sort([3, 5, 1, 2, 4], &2 <= &1) == [5,4,3,2,1]
    assert List.sort(['2', '3', '0', '11', '10']) == ['0', '10', '11', '2', '3']
    assert ['0', '2', '3', '10', '11'] == List.sort ['2', '3', '0', '11', '10'], fn a, b ->
      {na, _} = :string.to_integer a
      {nb, _} = :string.to_integer b
      na <= nb
    end
  end

  deftest :concat_1 do
    assert List.concat([[1,[2],3], [4], [5,6]]) == [1,[2],3,4,5,6]
  end

  deftest :concat_2 do
    assert List.concat([1,[2],3], [4,5]) == [1,[2],3,4,5]
  end

  deftest :reverse do
    assert List.reverse([1,2,3]) == [3,2,1]
  end

  deftest :uniq do
    assert List.uniq([1,2,3,2,1]) == [1,2,3]
  end

  deftest :duplicate do
    assert List.duplicate(1, 3) == [1,1,1]
    assert List.duplicate([1], 1) == [[1]]
  end

  deftest :find_index do
    assert List.find_index([], 'a') == nil
    assert List.find_index(['a'], 'b') == nil
    assert List.find_index(['a'], 'a') == 1
    assert List.find_index([1,2,4,3], 3) == 4
  end

  deftest :last do
    assert List.last([]) == nil
    assert List.last([1]) == 1
    assert List.last([1, 2, 3]) == 3
  end

  deftest :zip do
    assert List.zip([:a, :b], [1, 2]) == [{:a, 1}, {:b, 2}]
    assert List.zip([:a, :b], [1, 2, 3, 4]) == [{:a, 1}, {:b, 2}]
    assert List.zip([:a, :b, :c, :d], [1, 2]) == [{:a, 1}, {:b, 2}]
    assert List.zip([], [1]) == []
    assert List.zip([1], []) == []
    assert List.zip([], []) == []
  end

  deftest :zip_tuples do
    assert List.zip({:a, :b}, {1, 2}) == [{:a, 1}, {:b, 2}]
    assert List.zip([:a, :b], {1, 2}) == [{:a, 1}, {:b, 2}]
    assert List.zip({:a, :b}, [1, 2]) == [{:a, 1}, {:b, 2}]
  end

  deftest :zip_lists do
    assert List.zip([[1, 4], [2, 5], [3, 6]]) == [{1, 2, 3}, {4, 5, 6}]
    assert List.zip([[1, 4], [2, 5, 0], [3, 6]]) == [{1, 2, 3}, {4, 5, 6}]
    assert List.zip([[1], [2, 5], [3, 6]]) == [{1, 2, 3}]
    assert List.zip([[1, 4], [2, 5], []]) == []
  end

  deftest :unzip do
    assert List.unzip([{1, 2, 3}, {4, 5, 6}]) == [[1, 4], [2, 5], [3, 6]]
    assert List.unzip([{1, 2, 3}, {4, 5}]) == [[1, 4], [2, 5]]
    assert List.unzip([[1, 2, 3], [4, 5]]) == [[1, 4], [2, 5]]
  end

  deftest :keyfind do
    assert List.keyfind([a: 1, b: 2], :a, 1) == { :a, 1 }
    assert List.keyfind([a: 1, b: 2], 2, 2) == { :b, 2 }
    assert List.keyfind([a: 1, b: 2], :c, 1) == nil
  end

  deftest :keymember? do
    assert List.keymember?([a: 1, b: 2], :a, 1) == true
    assert List.keymember?([a: 1, b: 2], 2, 2) == true
    assert List.keymember?([a: 1, b: 2], :c, 1) == false
  end

  deftest :keydelete do
    assert List.keydelete([a: 1, b: 2], :a, 1) == [{ :b, 2 }]
    assert List.keydelete([a: 1, b: 2], 2, 2) == [{ :a, 1 }]
    assert List.keydelete([a: 1, b: 2], :c, 1) == [{ :a, 1 }, { :b, 2 }]
  end
end
