# -*- encoding: utf-8 -*-
require File.expand_path('./helper', File.dirname(__FILE__))

class TestRadixTree < Test::Unit::TestCase
  def setup
    # rt for RadixTree
    # ip for input
    @rt = RadixTree.new
    @ip = { 'aa' => 1, 'ab' => 2, 'bb' => 3, 'bc' => 4, 'a' => 5, 'abc' => 6 }
    @ip.each do |k, v|
      @rt[k] = v
    end
  end

  def test_aref_nil
    h = RadixTree.new
    h['abc'] = 1
    assert_equal nil, h['def']
  end

  def test_empty
    h = RadixTree.new
    h['abc'] = 0
    assert_equal nil, h['']
    h[''] = 1
    assert_equal 1, h['']
    h.delete('')
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

  def test_delete_compaction_middle
    h = RadixTree.new
    h['a'] = 1
    h['abc'] = 2
    h['bb'] = 3
    h['abcdefghi'] = 4
    h['abcdefghijzz'] = 5
    h['abcdefghikzz'] = 6
    assert_equal 7, h.dump_tree.split($/).size
    h.delete('a')
    assert_equal 6, h.dump_tree.split($/).size
    h['a'] = 1
    assert_equal 7, h.dump_tree.split($/).size
  end

  def test_delete_compaction_leaf
    h = RadixTree.new
    h['a'] = 1
    h['abc'] = 2
    h['bb'] = 3
    h['abcdefghijzz'] = 4
    assert_equal 5, h.dump_tree.split($/).size
    h['abcdefghikzz'] = 5
    assert_equal 7, h.dump_tree.split($/).size
    h.delete('abcdefghijzz')
    assert_equal 5, h.dump_tree.split($/).size
    h['abcdefghijzz'] = 4
    assert_equal 7, h.dump_tree.split($/).size
  end

  def test_each
    h, s = @rt, @ip
    assert_equal s.to_a.sort_by { |k, v| k }, h.each.sort_by { |k, v| k }
    #
    values = []
    h.each do |k, v|
      values << [k, v]
    end
    assert_equal h.to_a.sort_by { |k, v| k }, values.sort_by { |k, v| k }
  end

  def test_each_key
    h, s = @rt, @ip
    assert_equal s.keys.sort, h.each_key.sort
    #
    values = []
    h.each_key do |k|
      values << k
    end
    assert_equal s.keys.sort, values.sort
  end

  def test_each_value
    h, s = @rt, @ip
    assert_equal s.values.sort, h.each_value.sort
    #
    values = []
    h.each_value do |v|
      values << v
    end
    assert_equal h.values.sort, values.sort
  end

  def test_keys
    h, s = @rt, @ip
    assert_equal s.keys.sort, h.keys.sort
  end

  def test_values
    h, s = @rt, @ip
    assert_equal s.values.sort, h.values.sort
  end

  def test_to_s
    h = RadixTree.new
    h[:abc] = 1
    assert_equal 1, h["abc"]
    assert_equal 1, h[:abc]
  end

  def test_key?
    h = RadixTree.new
    assert !h.key?('a')
    s = { 'aa' => 1, 'ab' => 2, 'bb' => 3, 'bc' => 4, 'a' => 5, 'abc' => 6 }
    s.each do |k, v|
      h[k] = v
    end
    assert h.key?('a')
  end

  def test_default
    assert_raise(ArgumentError) do
      RadixTree.new('both') { :not_allowed }
    end

    h = RadixTree.new('abc')
    assert_equal 'abc', h['foo']
    assert_equal 'abc', h['bar']
    assert h['baz'].object_id == h['qux'].object_id

    h = RadixTree.new { [1, 2] }
    assert_equal [1, 2], h['foo']
    assert_equal [1, 2], h['bar']
    assert h['baz'].object_id != h['qux'].object_id
  end

  def test_to_hash
    h, s = @rt, @ip
    assert_equal s, h.to_hash
  end

  def test_clear
    assert_equal @ip, @rt.to_hash
    @rt.clear
    assert_equal 0, @rt.size
    assert @rt.to_hash.empty?
  end

  def test_delete_if
    h, s = @rt, @ip
    assert_equal 6, h.size
    h.delete_if do |k,v|
        v > 3
    end
    assert_equal 3, h.size
    assert_equal 1, h['aa']
    assert_equal 2, h['ab']
    assert_equal 3, h['bb']
    assert_equal nil, h['bc']
    assert_equal nil, h['a']
    assert_equal nil, h['abc']
  end

  def test_dup
    h = RadixTree.new
    s = { 'aa' => 1, 'ab' => 2, 'bb' => 3 }
    s.each do |k, v|
      h[k] = v
    end
    assert_equal 3, h.size
    assert_equal 1, h['aa']
    assert_equal 2, h['ab']
    assert_equal 3, h['bb']
    h2 = h.dup
    h2['aa'] = 4
    h2['a'] = 5

    assert_equal 3, h.size
    assert_equal 1, h['aa']
    assert_equal 2, h['ab']
    assert_equal 3, h['bb']
    assert_equal 4, h2.size
    assert_equal 4, h2['aa']
    assert_equal 2, h2['ab']
    assert_equal 3, h2['bb']
    assert_equal 5, h2['a']
  end

  def test_reject
    h, s = @rt, @ip
    h2 = h.reject do |k,v|
        v > 3
    end
    assert_equal 6, h.size
    assert_equal 1, h['aa']
    assert_equal 2, h['ab']
    assert_equal 3, h['bb']
    assert_equal 4, h['bc']
    assert_equal 5, h['a']
    assert_equal 6, h['abc']

    assert_equal 3, h2.size
    assert_equal 1, h2['aa']
    assert_equal 2, h2['ab']
    assert_equal 3, h2['bb']
    assert_equal nil, h2['bc']
    assert_equal nil, h2['a']
    assert_equal nil, h2['abc']
  end

  def test_reject!
    h, s = @rt, @ip
    h2 = h.reject! do |k,v|
        v > 8
    end
    assert_equal 6, h.size
    assert_equal 1, h['aa']
    assert_equal 2, h['ab']
    assert_equal 3, h['bb']
    assert_equal 4, h['bc']
    assert_equal 5, h['a']
    assert_equal 6, h['abc']

    assert_equal nil, h2
  end

  def fetch!
    h = RadixTree.new
    s = { 'aa' => 1, 'ab' => 2 }
    s.each do |k, v|
      h[k] = v
    end
    assert_equal 1, h.fetch('aa')
    assert_equal 'df value', h.fetch('aac', 'df value')
    assert_equal "aac:df value from block", h.fetch('aac') {|k| "#{k}:df value from block" }
  end

  def test_values_at
    h, s = @rt, @ip
    ks = s.keys.shuffle[0..2]
    vs = h.values_at(*ks)
    for i in (0..(ks.size)) do
      assert_equal vs[i], h[ks[i]]
    end
  end

  def test_replace
    h = RadixTree.new
    s = { 'aa' => 1, 'ab' => 2 }
    s2 = { 'bz' => 3, 'kk' => 4 }
    s.each do |k, v|
      h[k] = v
    end
    assert_equal 1, h['aa']
    assert_equal 2, h['ab']
    h.replace(s2)
    assert_equal 3, h['bz']
    assert_equal 4, h['kk']
  end

  def test_key
    h, s = @rt, @ip
    assert_equal 'aa', h.key(1)
    assert_equal 'bb', h.key(3)
    assert_equal 'bc', h.key(4)
  end

  def test_shift
    h, s = @rt, @ip
    k, v = h.shift
    assert_equal 'a', k
    assert_equal 5, v
    assert_equal 1, h['aa']
    assert_equal 2, h['ab']
    assert_equal 3, h['bb']
    assert_equal 4, h['bc']
    assert_equal 6, h['abc']
  end

  def test_has_value?
    h, s = @rt, @ip
    assert_equal true, h.has_value?(3)
    assert_equal true, h.has_value?(4)
    assert_equal true, h.value?(5)
    assert_equal true, h.value?(6)
    assert_equal false, h.has_value?(7)
  end

  def test_=
    h, s = @rt, @ip
    h2 = RadixTree.new
    s.each do |k, v|
      h2[k] = v
    end
    assert_equal true, (h==h2)
    tk, tv= h2.shift
    assert_equal false, (h==h2)
    h2[tk] = tv+3
    assert_equal false, (h==h2)
  end

  def test_eql?
    h, s = @rt, @ip
    h2 = RadixTree.new
    s.each do |k, v|
      h2[k] = v
    end
    assert_equal true, (h.eql?(h2))
    tk, tv= h2.shift
    assert_equal false, (h.eql?(h2))
    h2[tk] = tv.to_s
    assert_equal false, (h.eql?(h2))
  end
  #@ip = { 'aa' => 1, 'ab' => 2, 'bb' => 3, 'bc' => 4, 'a' => 5, 'abc' => 6 }
  if RUBY_VERSION >= '1.9.0'
    def test_encoding
      h = RadixTree.new
      s = { 'ああ' => 1, 'あい' => 2, 'いい' => 3, 'いう' => 4, 'あ' => 5, 'あいう' => 6 }
      s.each do |k, v|
        h[k] = v
      end
      assert_equal 6, h.size
      s.each do |k, v|
        assert_equal v, h[k]
      end
      str = 'ああ'
      str.force_encoding('US-ASCII')
      assert_equal nil, h[str]
    end
  end
end
