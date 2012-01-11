# Originally written by Masatoshi Seki (https://twitter.com/m_seki)
# http://d.hatena.ne.jp/m_seki/20080521#1211297884
require 'pp'

class Sbb
  Node = Struct.new(:key, :value, :lh, :rh, :left, :right)
  
  class Search
    def initialize(key)
      @key = key
      @found = nil
      @created = false
    end
    attr_accessor :found, :created

    def compare(a, b)
      a <=> b
    end

    def fetch(node)
      return nil unless node
      cmp = compare(@key, node.key)
      if cmp < 0
        fetch(node.left)
      elsif cmp > 0
        fetch(node.right)
      else
        node
      end
    end

    def create_node
      node = Node.new
      node.key = @key
      @found = node
      node
    end

    def search(node, h)
      return create_node, 2 unless node

      cmp = compare(@key, node.key)
      if cmp < 0
        return search_left(node, h)
      elsif cmp > 0
        return search_right(node, h)
      else
        @found = node
        return node, h
      end
    end

    def rotate_LL(node)
      p1 = node.left
      node.left = p1.right
      p1.right = node
      node = p1
      return node
    end

    def rotate_LR(node)
      p1 = node.left
      p2 = p1.right
      p1.right = p2.left
      p2.left = p1
      node.left = p2.right
      p2.right = node
      node = p2
      return node
    end

    def search_left(node, h)
      node.left, h = search(node.left, h)
      if h > 0
        if node.lh
          h = 2
          node.lh = false
          if node.left.lh
            node = rotate_LL(node)
            node.lh = false
          elsif node.left.rh
            node = rotate_LR(node)
            node.left.rh = false
          end
        else
          h -= 1
          node.lh = true if h > 0
        end
      end
      return node, h
    end

    def rotate_RR(node)
      p1 = node.right
      node.right = p1.left
      p1.left = node
      node = p1
      return node
    end

    def rotate_RL(node)
      p1 = node.right
      p2 = p1.left
      p1.left = p2.right
      p2.right= p1
      node.right = p2.left
      p2.left = node
      node = p2
      return node
    end

    def search_right(node, h)
      node.right, h = search(node.right, h)
      if h > 0
        if node.rh
          h = 2
          node.rh = false
          if node.right.rh
            node = rotate_RR(node)
            node.rh = false
          elsif node.right.lh
            node = rotate_RL(node)
            node.right.lh = false
          end
        else
          h -= 1
          node.rh = true if h > 0
        end
      end
      return node, h
    end
  end

  def initialize
    @root = nil
  end

  def search(key)
    ctx = Search.new(key)
    @root, h = ctx.search(@root, 0)
    ctx
  end

  def fetch(key)
    ctx = Search.new(key)
    ctx.fetch(@root)
  end

  def inorder(cur=@root, depth=0, &blk)
    return nil unless cur
    inorder(cur.left, depth + 1, &blk)
    yield(cur.key, depth)
    inorder(cur.right, depth + 1, &blk)
  end
end

sbb = Sbb.new
10000.times do |n|
  sbb.search(rand(n))
end

m = -1
sbb.inorder {|v, d|
  print '.'
  if m <= v
    m = v
  else
    print "oops"
    exit
  end
}

puts
pp sbb.fetch(312)
