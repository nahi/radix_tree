require 'benchmark'
require 'radix_tree'

random = Random.new(0)

TIMES = 100000
key_size = 10

Benchmark.bmbm do |bm|
  bm.report('random') do
    h = RadixTree.new
    TIMES.times do
      random.bytes(key_size)
    end
  end

  bm.report('Hash aset') do
    h = Hash.new
    TIMES.times do
      h[random.bytes(key_size)] = 1
    end
  end

  bm.report('RadixTree aset') do
    h = RadixTree.new
    TIMES.times do
      h[random.bytes(key_size)] = 1
    end
  end

  bm.report('Hash aset+aref') do
    h = Hash.new
    TIMES.times do
      h[random.bytes(key_size)] = 1
      h[random.bytes(key_size)]
    end
  end

  bm.report('RadixTree aset+aref') do
    h = RadixTree.new
    TIMES.times do
      h[random.bytes(key_size)] = 1
      h[random.bytes(key_size)]
    end
  end
end
