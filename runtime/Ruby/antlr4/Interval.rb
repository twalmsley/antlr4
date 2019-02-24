class Interval
  INTERVAL_POOL_MAX_VALUE = 1000


  @@cache = []

  attr_accessor :a
  attr_accessor :b

  class << self
    attr_accessor :creates
    attr_accessor :misses
    attr_accessor :hits
    attr_accessor :outOfRange
  end
  @@creates = 0
  @@misses = 0
  @@hits = 0
  @@outOfRange = 0

  def initialize(a, b)
    @a = a
    @b = b
  end

  INVALID = Interval.new(-1, -2)

  def self.of(a, b)
    if (a != b || a < 0 || a > INTERVAL_POOL_MAX_VALUE)
      return Interval.new(a, b)
    end
    if (@@cache[a] == nil)
      @@cache[a] = Interval.new(a, a)
    end
    return @@cache[a]
  end

  def length
    if (b < a)
      return 0
    end
    return b - a + 1
  end

  def ==(o)
    if (o == nil || !(o.is_a? Interval))
      return false
    end
    return @a == o.a && @b == o.b
  end

  def hash
    hash = 23
    hash = hash * 31 + @a
    hash = hash * 31 + @b
    return hash
  end

  def startsBeforeDisjoint(other)
    return @a < other.a && @b < other.a
  end

  def startsBeforeNonDisjoint(other)
    return @a <= other.a && @b >= other.a
  end

  def startsAfter(other)
    return @a > other.a
  end

  def startsAfterDisjoint(other)
    return @a > other.b
  end

  def startsAfterNonDisjoint(other)
    return @a > other.a && @a <= other.b
  end

  def disjoint(other)
    return startsBeforeDisjoint(other) || startsAfterDisjoint(other)
  end

  def adjacent(other)
    return @a == other.b + 1 || @b == other.a - 1
  end

  def properlyContains(other)
    return other.a >= @a && other.b <= @b
  end

  def union(other)
    return Interval.of(Math.min(a, other.a), Math.max(b, other.b))
  end

  def intersection(other)
    return Interval.of(Math.max(a, other.a), Math.min(b, other.b))
  end

  def differenceNotProperlyContained(other)
    diff = null
    if (other.startsBeforeNonDisjoint(this))

      diff = Interval.of(Math.max(@a, other.b + 1),
                         @b)

    elsif (other.startsAfterNonDisjoint(this))

      diff = Interval.of(@a, other.a - 1)
    end
    return diff
  end

  def to_s
    return a.to_s + ".." + b.to_s
  end
end
