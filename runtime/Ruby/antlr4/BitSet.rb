require 'set'

class BitSet

  attr_reader :bits

  def initialize
    @bits = Set.new
  end

  def set(x)
    @bits.add x
  end

  def get(x)
    (@bits.include? x) ? true : false
  end

  def cardinality
    @bits.length
  end

  def or(bitSet)
    bitSet.bits.each do |bit|
      set(bit)
    end
  end

  def to_s
    v = Array.new(@bits.size, 0)
    @bits.each do |bit|
      v[bit] = 1
    end
    buf = "["
    v.each do |c|
      buf << c.to_s
    end
    buf << "]"
    return buf
  end
end