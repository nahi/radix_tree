# Naive implementation of Radix Tree for avoiding DoS via Algorithmic
# Complexity Attacks.
#
# 25 times slower for 10 bytes key, 100000 elements insertion
# 10 times slower for 10 bytes key, 100000 elements retrieval
#
# TODO: Implement following methods for Hash compatibility.
# * delete_if
# * reject
# * reject!
# * fetch
# * values_at
# * replace
# * key
# * shift
# * has_value?/value?
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

    def keys
      collect { |k, v| k }
    end

    def values
      collect { |k, v| v }
    end

    def store(key, value)
      if same_key?(key)
        @value = value
      else
        pos = head_match_length(key)
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

    def retrieve(key)
      if same_key?(key)
        @value
      elsif !@children
        UNDEFINED
      else
        pos = head_match_length(key)
        if child = find_child(key[pos])
          child.retrieve(key)
        else
          UNDEFINED
        end
      end
    end

    def delete(key)
      if same_key?(key)
        value, @value = @value, UNDEFINED
        value
      elsif !@children
        nil
      else
        pos = head_match_length(key)
        if child = find_child(key[pos])
          value = child.delete(key)
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
        child.store(key, value)
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

    def head_match_length(check)
      0.upto(@index) do |idx|
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
      to_enum { |k, v| [k, v] }
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
      to_enum { |k, v| k }
    end
  end

  def each_value
    if block_given?
      @root.each do |k, v|
        yield v
      end
      self
    else
      to_enum { |k, v| v }
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
    @root.store(key.to_s, value)
  end
  alias store []=

  def key?(key)
    @root.retrieve(key.to_s) != Node::UNDEFINED
  end
  alias has_key? key?

  def [](key)
    value = @root.retrieve(key.to_s)
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
    @root.delete(key.to_s)
  end

  def dump_tree(io = '')
    @root.dump_tree(io)
    io
  end

  def to_hash
    inject({}) { |r, (k, v)| r[k] = v; r }
  end

  def to_enum
    Enumerator.new { |yielder|
      @root.each do |k, v|
        yielder << yield(k, v)
      end
    }
  end
end
