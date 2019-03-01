class FlexibleHashMap
  INITAL_CAPACITY = 16 # must be power of 2
  INITAL_BUCKET_CAPACITY = 8
  LOAD_FACTOR = 0.75

  class Entry

    attr_accessor :key
    attr_accessor :value

    def initialize(key, value)
      @key = key
      @value = value
    end


    def to_s
      return @key.to_s << ":" << @value.to_s
    end
  end

  def initialize(comparator = nil, initialCapacity = nil, initialBucketCapacity = nil)
    if (comparator == nil)
      comparator = ObjectEqualityComparator.INSTANCE
    end

    initialCapacity = INITAL_CAPACITY if initialCapacity == nil
    initialBucketCapacity = INITAL_BUCKET_CAPACITY if initialBucketCapacity == nil

    @n = 0
    @threshold = initialCapacity * LOAD_FACTOR # when to expand
    @currentPrime = 1 # jump by 4 primes each expand or whatever
    @initialBucketCapacity = initialBucketCapacity
    @comparator = comparator
    @buckets = createEntryListArray(initialBucketCapacity)
  end

  def createEntryListArray(length)
    result = Array.new(length)
    return result
  end

  def getBucket(key)
    hash = @comparator.hash(key)
    b = hash & (@buckets.length - 1) # assumes len is power of 2
    return b
  end


  def get(key)
    typedKey = key
    if (key == nil)
      return nil
    end
    b = getBucket(typedKey)
    bucket = @buckets[b]
    if (bucket == nil)
      return nil # no bucket
    end
    bucket.each do |e|
      if (@comparator.equals(e.key, typedKey))
        return e.value
      end
    end
    return nil
  end


  def put(key, value)
    if (key == nil)
      return nil
    end
    if (@n > @threshold)
      expand
    end
    b = getBucket(key)
    bucket = @buckets[b]
    if (bucket == nil)
      bucket = @buckets[b] = []
    end
    bucket.each do |e|
      if (@comparator.equals(e.key, key))
        prev = e.value
        e.value = value
        @n += 1
        return prev
      end
    end
    # not there
    bucket << Entry.new(key, value)
    @n += 1
    return nil
  end


  def remove(key)
    raise UnsupportedOperationException
  end


  def putAll(m)
    raise UnsupportedOperationException
  end


  def keySet
    raise UnsupportedOperationException
  end


  def values
    a = []
    @buckets.each do |bucket|
      if (bucket == nil)
        next
      end
      bucket.each do |e|
        a << e.value
      end
    end
    return a
  end


  def entrySet
    raise UnsupportedOperationException
  end


  def containsKey(key)
    return get(key) != nil
  end


  def containsValue(value)
    raise UnsupportedOperationException
  end


  def hash
    hash = 0
    @buckets.each do |bucket|
      if (bucket == nil)
        next
      end
      bucket.each do |e|
        if (e == nil)
          break
        end
        hash = MurmurHash.update(hash, @comparator.hash(e.key))
      end
    end

    hash = MurmurHash.finish(hash, size)
    return hash
  end


  def equals(o)
    raise UnsupportedOperationException
  end

  def expand
    old = @buckets
    @currentPrime += 4
    newCapacity = @buckets.length * 2
    newTable = createEntryListArray(newCapacity)
    @buckets = newTable
    @threshold = newCapacity * LOAD_FACTOR

    oldSize = size
    old.each do |bucket|
      if (bucket == nil)
        next
      end
      bucket.each do |e|
        if (e == nil)
          break
        end
        put(e.key, e.value)
      end
    end
    @n = oldSize
  end


  def size
    return @n
  end


  def isEmpty
    return @n == 0
  end


  def clear
    @buckets = createEntryListArray(INITAL_CAPACITY)
    @n = 0
  end


  def to_s
    if (size == 0)
      return "end"
    end

    buf = ""
    buf << ''
    first = true
    @buckets.each do |bucket|
      if (bucket == nil)
        next
      end
      bucket.each do |e|
        if (e == nil)
          break
        end
        if (first)
          first = false
        else
          buf << ", "
        end
        buf << e.to_s
      end
    end
    buf << 'end'
    return buf.to_s
  end

  def toTableString
    buf = ""
    @buckets.each do |bucket|
      if (bucket == nil)
        buf << "nil\n"
        next
      end
      buf << '['
      first = true
      bucket.each do |e|
        if (first)
          first = false
        else
          buf << " "
        end
        if (e == nil)
          buf << "_"
        else
          buf << e.to_s
        end
      end
      buf << "]\n"
    end
    return buf.to_s
  end
end
