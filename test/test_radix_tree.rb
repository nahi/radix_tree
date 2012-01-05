require File.expand_path('./helper', File.dirname(__FILE__))

class TestRadixTree < Test::Unit::TestCase
  def test_aref_nil
    h = RadixTree.new
    h['abc'] = 1
    assert_equal nil, h['def']
  end

  def test_aref_empty
    h = RadixTree.new
    assert_equal nil, h['']
  end

  def test_aref_single
    h = RadixTree.new
    h['abc'] = 1
    assert_equal 1, h['abc']
  end

  def test_aref_double
    h = RadixTree.new
    h['abc'] = 1
    h['def'] = 2
    assert_equal 1, h['abc']
    assert_equal 2, h['def']
  end

  def test_aset_override
    h = RadixTree.new
    h['abc'] = 1
    h['abc'] = 2
    assert_equal 2, h['abc']
  end

  def test_split
    h = RadixTree.new
    h['abcd'] = 1
    assert_equal 1, h['abcd']
    h['abce'] = 2
    assert_equal 1, h['abcd']
    assert_equal 2, h['abce']
    h['abd'] = 3
    assert_equal 1, h['abcd']
    assert_equal 2, h['abce']
    assert_equal 3, h['abd']
    h['ac'] = 4
    assert_equal 1, h['abcd']
    assert_equal 2, h['abce']
    assert_equal 3, h['abd']
    assert_equal 4, h['ac']
  end

  def test_split_and_assign
    h = RadixTree.new
    h['ab'] = 1
    h['a'] = 2
    assert_equal 1, h['ab']
    assert_equal 2, h['a']
  end

  def test_push
    h = RadixTree.new
    assert_equal 0, h.size
    h['a'] = 1
    assert_equal 1, h['a']
    h['ab'] = 2
    assert_equal 1, h['a']
    assert_equal 2, h['ab']
    h['abc'] = 3
    assert_equal 1, h['a']
    assert_equal 2, h['ab']
    assert_equal 3, h['abc']
    h['abd'] = 4
    assert_equal 1, h['a']
    assert_equal 2, h['ab']
    assert_equal 3, h['abc']
    assert_equal 4, h['abd']
    h['ac'] = 5
    assert_equal 1, h['a']
    assert_equal 2, h['ab']
    assert_equal 3, h['abc']
    assert_equal 4, h['abd']
    assert_equal 5, h['ac']
    h['b'] = 6
    assert_equal 1, h['a']
    assert_equal 2, h['ab']
    assert_equal 3, h['abc']
    assert_equal 4, h['abd']
    assert_equal 5, h['ac']
    assert_equal 6, h['b']
    assert_equal ['a', 'ab', 'abc', 'abd', 'ac', 'b'].sort, h.keys.sort
    assert_equal 6, h.size
  end

  def test_delete
    h = RadixTree.new
    h['a'] = 1
    h['ab'] = 2
    h['abc'] = 3
    h['abd'] = 4
    h['ac'] = 5
    h['b'] = 6
    assert_equal 6, h.size
    assert_equal nil, h.delete('XXX')
    # delete leaf
    assert_equal 4, h.delete('abd')
    assert_equal 5, h.size
    assert_equal 1, h['a']
    assert_equal 2, h['ab']
    assert_equal 3, h['abc']
    assert_equal nil, h['abd']
    assert_equal 5, h['ac']
    assert_equal 6, h['b']
    # delete single leaf node
    assert_equal 2, h.delete('ab')
    assert_equal 4, h.size
    assert_equal 1, h['a']
    assert_equal nil, h['ab']
    assert_equal 3, h['abc']
    assert_equal nil, h['abd']
    assert_equal 5, h['ac']
    assert_equal 6, h['b']
    # delete multiple leaf node
    assert_equal 1, h.delete('a')
    assert_equal 3, h.size
    assert_equal nil, h['a']
    assert_equal nil, h['ab']
    assert_equal 3, h['abc']
    assert_equal nil, h['abd']
    assert_equal 5, h['ac']
    assert_equal 6, h['b']
    assert_equal ['abc', 'ac', 'b'].sort, h.keys.sort
    # delete rest
    assert_equal 3, h.delete('abc')
    assert_equal 5, h.delete('ac')
    assert_equal 6, h.delete('b')
    assert_equal 0, h.size
    assert h.empty?
  end
end
