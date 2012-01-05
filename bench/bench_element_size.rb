require 'benchmark'
require 'radix_tree'

random = Random.new(0)

# What an artificial example! :)
key_size = 10000
elements = 10

Benchmark.bm(20) do |bm|
  [10000, 20000, 50000, 100000, 200000, 500000, 1000000, 2000000].each do |times|
    h = Hash.new
    t = RadixTree.new
    elements.times do
      k = random.bytes(key_size)
      h[k] = 1
      t[k] = 1
    end

    k = random.bytes(key_size)

    bm.report("Hash: #{times}") do
      times.times do
        h[k]
      end
    end

    bm.report("RadixTree: #{times}") do
      times.times do
        t[k]
      end
    end
  end
end
