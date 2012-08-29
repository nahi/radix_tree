# Naive implementation of Radix Tree for avoiding DoS via Algorithmic
# Complexity Attacks.
#
# 25 times slower for 10 bytes key, 100000 elements insertion
# 10 times slower for 10 bytes key, 100000 elements retrieval
#
# TODO: Implement following methods for Hash compatibility.
# * delete_if   Done
# * dup         Done
# * reject      Done
# * reject!     Done
# * fetch       Done
# * values_at   Done
# * replace     Done
# * key         Done
# * shift       Done
# * has_value?  Done
# * value?      Done
# * ==
# * eql?
# * hash
#
# TODO: Implement following features for utilizing strength of Radix Tree.
# * find predecessor
# * find successor
# * find_all by start string
# * delete_all by start string
#
class RadixTree
  include Enumerable

  class Node
    UNDEFINED = Object.new

    attr_reader :key, :index
    attr_reader :value
    attr_reader :children

    def initialize(key, index, value = UNDEFINED, children = nil)
      @key, @index, @value, @children = key, index, value, children
    end

    def label
      @key[0, @index]
    end

    def undefined?
      @value == UNDEFINED
    end

    def empty?
      !@children and undefined?
    end

    def size
      count = @value != UNDEFINED ? 1 : 0
      if @children
        @children.inject(count) { |r, (k, v)| r + v.size }
      else
        count
      end
    end

    def each(&block)
      if @value != UNDEFINED
        block.call [label, @value]
      end
      if @children
        @children.each_value do |child|
          child.each(&block)
        end
      end
    end
    
    def each_key
      each do |k, v|
        yield k
      end
    end
    
    def each_value
      each do |k, v|
        yield v
      end
    end

    def keys
      collect { |k, v| k }
    end

    def values
      collect { |k, v| v }
    end

    def store(key, head, value)
      if same_key?(key)
        @value = value
      else
        pos = head_match_size(key, head)
        if pos == @index
          push(key, value)
        else
          split(pos)
          if same_key?(key)
            @value = value
          else
            push(key, value)
          end
        end
      end
    end

    def retrieve(key, head)
      if same_key?(key)
        @value
      else
        if @children
          pos = head_match_size(key, head)
          if child = find_child(key[pos])
            return child.retrieve(key, @index)
          end
        end
        UNDEFINED
      end
    end

    def delete(key, head)
      if same_key?(key)
        value, @value = @value, UNDEFINED
        value
      elsif !@children
        nil
      else
        pos = head_match_size(key, head)
        if child = find_child(key[pos])
          value = child.delete(key, @index)
          if value and child.undefined?
            reap(child)
          end
          value
        end
      end
    end

    def dump_tree(io, indent = '')
      indent += '  '
      if undefined?
        io << sprintf("#<%s:0x%010x %s>", self.class.name, __id__, label.inspect)
      else
        io << sprintf("#<%s:0x%010x %s> => %s", self.class.name, __id__, label.inspect, @value.inspect)
      end
      if @children
        @children.each do |k, v|
          io << $/ + indent
          v.dump_tree(io, indent)
        end
      end
    end

    def dup
        if @children
          children_dup = Hash.new
          @children.each do |k,v|
            children_dup[k] = v.dup
          end
        else
          children_dup = nil
        end
        Node.new(@key, @index, @value, children_dup)
    end
    alias clone dup

    private

    def same_key?(key)
      @index == key.size and @key.start_with?(key)
    end

    def collect
      pool = []
      each do |key, value|
        pool << yield(key, value)
      end
      pool
    end

    def push(key, value)
      if @children && child = find_child(key[@index])
        child.store(key, @index, value)
      else
        add_child(Node.new(key, key.size, value))
      end
    end

    def split(pos)
      child = Node.new(@key, @index, @value, @children)
      @index, @value, @children = pos, UNDEFINED, nil
      add_child(child)
    end

    def reap(child)
      if !child.children
        delete_child(child)
      elsif child.children.size == 1
        # pull up the grand child as a child
        delete_child(child)
        add_child(child.children.shift[1])
      end
    end

    def head_match_size(check, head)
      head.upto(@index) do |idx|
        if check[idx] != @key[idx]
          return idx
        end
      end
      @index
    end

    def find_child(char)
      @children[char]
    end

    def add_child(child)
      char = child.key[@index]
      @children ||= {}
      @children[char] = child
    end

    def delete_child(child)
      char = child.key[@index]
      @children.delete(char)
      if @children.empty?
        @children = nil
      end
    end
  end

  DEFAULT = Object.new

  attr_accessor :default
  attr_reader :default_proc
  
  def initialize(default = DEFAULT, &block)
    if block && default != DEFAULT
      raise ArgumentError, 'wrong number of arguments'
    end
    @root = Node.new('', 0)
    @default = default
    @default_proc = block
  end

  def empty?
    @root.empty?
  end

  def size
    @root.size
  end
  alias length size

  def each(&block)
    if block_given?
      @root.each(&block)
      self
    else
      Enumerator.new(@root)
    end
  end
  alias each_pair each

  def each_key
    if block_given?
      @root.each do |k, v|
        yield k
      end
      self
    else
      Enumerator.new(@root, :each_key)
    end
  end

  def each_value
    if block_given?
      @root.each do |k, v|
        yield v
      end
      self
    else
      Enumerator.new(@root, :each_value)
    end
  end

  def keys
    @root.keys
  end

  def values
    @root.values
  end

  def clear
    @root = Node.new('', 0)
  end

  def []=(key, value)
    @root.store(key.to_s, 0, value)
  end
  alias store []=

  def key?(key)
    @root.retrieve(key.to_s, 0) != Node::UNDEFINED
  end
  alias has_key? key?

  def [](key)
    value = @root.retrieve(key.to_s, 0)
    if value == Node::UNDEFINED
      if @default != DEFAULT
        @default
      elsif @default_proc
        @default_proc.call
      else
        nil
      end
    else
      value
    end
  end

  def delete(key)
    @root.delete(key.to_s, 0)
  end

  def dump_tree(io = '')
    @root.dump_tree(io)
    io
  end

  def to_hash
    inject({}) { |r, (k, v)| r[k] = v; r }
  end

  def delete_if(&block)
    if block_given?
      temp = []
      @root.each do |key, value|
        if block.call key, value
            temp << key
        end
      end
      temp.each do |k|
        @root.delete(k, 0)
      end
      self
    else
      Enumerator.new(@root)
    end
  end

  def dup
      if @default != DEFAULT then
        rt = RadixTree.new(@default)
      elsif @default_proc then
             rt = RadixTree.new(@default_proc.to_proc)
      else
        rt = RadixTree.new
      end
      rt.root = @root.dup
      rt
  end
  alias clone dup

  def reject(&block)
    if block_given?
      self.dup.delete_if(&block)
    else
      Enumerator.new(@root)
    end
  end

  def reject!(&block)
    if block_given?
      temp = []
      @root.each do |key, value|
        if block.call key, value
            temp << key
        end
      end
      if temp.empty?
        nil
      else
        temp.each do |k|
          @root.delete(k, 0)
        end
        self
      end
    else
      Enumerator.new(@root)
    end
  end

  def fetch(key, *args, &block)
    if args.size > 0 && block
      raise ArgumentError, 'wrong number of arguments'
    elsif self[key]
      self[key]
    elsif args.size == 1
      args[0]
    elsif block
      block.call key
    else
      raise KeyError, 'can\'t find the key'
    end
  end

  def values_at(*args)
    vs = []
    args.each do |a|
      vs << self[a]
    end
    vs
  end

  def replace(h)
    self.clear
    h.each do |k,v|
      self[k] = v
    end
  end

  def key(value)
    self.each do |k,v|
      return k if v == value
      nil
    end
  end

  def shift
    self.each do |k,v|
      self.delete(k)
      return [k, v]
    end
  end

  def has_value?(value)
    self.each do |k,v|
      return true if value == v 
    end
    false
  end
  alias value? has_value?

  def ==(oh)
    return false if self.size != oh.size
    self.each_key do |k|
      return false if self[k] != oh[k]
    end
    true
  end

  def eql?(oh)
    return false if self.size != oh.size
    self.each_key do |k|
      return false unless self[k].eql?(oh[k])
    end
    true
  end

  protected
  attr_accessor :root

end
