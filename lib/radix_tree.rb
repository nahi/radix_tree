# Naive implementation of Radix Tree for avoiding DoS via Algorithmic
# Complexity Attacks.
#
# 25 times slower for 10 bytes key insertion
# 20 times slower for 10 bytes key retrieval
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

    attr_reader :key, :value
    attr_reader :children

    def initialize(key, value = UNDEFINED, children = nil)
      @key, @value, @children = key, value, children
    end

    def empty?
      @children.nil? and @value == UNDEFINED
    end

    def size
      count = @value != UNDEFINED ? 1 : 0
      if @children
        @children.inject(count) { |r, (k, v)| r + v.size }
      else
        count
      end
    end

    def each(prefix, &block)
      prefix += @key
      if @value != UNDEFINED
        block.call(prefix, @value)
      end
      if @children
        @children.each do |key, child|
          child.each(prefix, &block)
        end
      end
    end

    def keys(prefix)
      collect(prefix) { |k, v| k }
    end

    def values(prefix)
      collect(prefix) { |k, v| v }
    end

    def store(key, value)
      if @key == key
        @value = value
      else
        index = head_match_length(key)
        if index == @key.bytesize
          push(key[index..-1], value)
        else
          split(index)
          # search again after split the node
          store(key, value)
        end
      end
    end

    def retrieve(key)
      if @key == key
        @value
      elsif !@children
        UNDEFINED
      else
        key = child_key(key)
        if child = find_child(key)
          child.retrieve(key)
        else
          UNDEFINED
        end
      end
    end

    def delete(key)
      if @key == key
        value, @value = @value, UNDEFINED
        value
      elsif !@children
        nil
      else
        key = child_key(key)
        if child = find_child(key)
          value = child.delete(key)
          if value and child.children.nil?
            delete_child(child)
          end
          value
        end
      end
    end

    private

    def collect(prefix)
      pool = []
      each(prefix) do |key, value|
        pool << yield(key, value)
      end
      pool
    end

    def push(key, value)
      if child = find_child(key)
        child.store(key, value)
      else
        add_child(Node.new(key, value))
      end
    end

    def split(index)
      @key, new_key = @key[0, index], @key[index..-1]
      child = Node.new(new_key, @value, @children)
      @value, @children = UNDEFINED, nil
      add_child(child)
    end

    def child_key(key)
      index = head_match_length(key)
      key[index..-1]
    end

    # assert: check != @key
    def head_match_length(check)
      0.upto([check.bytesize, @key.bytesize].min) do |index|
        if check[index] != @key[index]
          return index
        end
      end
      raise 'assert: check != @key'
    end

    def find_child(key)
      if @children
        @children[key[0]]
      end
    end

    def add_child(child)
      @children ||= {}
      @children[child.key[0]] = child
    end

    def delete_child(child)
      @children.delete(child.key[0])
      if @children.empty?
        @children = nil
      end
    end
  end

  DEFAULT = Object.new
  
  def initialize(default = DEFAULT, &block)
    if block && default != DEFAULT
      raise ArgumentError, 'wrong number of arguments'
    end
    @root = Node.new('')
    @default = default
    @default_proc = block
  end

  def empty?
    @root.empty?
  end

  def size
    @root.size
  end

  def each(&block)
    @root.each('', &block)
  end

  def keys
    @root.keys('')
  end

  def values
    @root.values('')
  end

  def []=(key, value)
    @root.store(key.to_s, value)
  end

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
end
