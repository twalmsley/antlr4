require '../antlr4/ObjectEqualityComparator'

class Array2DHashSet
  INITAL_CAPACITY = 16 # must be power of 2
  INITAL_BUCKET_CAPACITY = 8
  LOAD_FACTOR = 0.75

  def initialize(comparator = nil, initialCapacity = INITAL_CAPACITY, initialBucketCapacity = INITAL_BUCKET_CAPACITY)
    if (comparator == nil)
      @comparator = ObjectEqualityComparator.instance
    else
      @comparator = comparator
    end
    @nElements = 0
    @initialBucketCapacity = initialBucketCapacity
    @threshold = (initialBucketCapacity * LOAD_FACTOR).floor # when to expand
    @currentPrime = 1 # jump by 4 primes each expand or whatever
    @buckets = createBuckets(initialCapacity)
  end


  def getOrAdd(o)
    if (@nElements > @threshold)
      expand()
    end
    return getOrAddImpl(o)
  end

  def getOrAddImpl(o)
    b = getBucket(o)
    bucket = @buckets[b]

# NEW BUCKET
    if (bucket == nil)
      bucket = createBucket(@initialBucketCapacity)
      bucket[0] = o
      @buckets[b] = bucket
      @nElements += 1
      return o
    end

# LOOK FOR IT IN BUCKET
    i = 0
    while i < bucket.length
      existing = bucket[i]
      if (existing == nil) # empty slot not there, add.
        bucket[i] = o
        @nElements += 1
        return o
      end
      if (@comparator.equals(existing, o))
        return existing # found existing, quit
      end
      i += 1
    end

# FULL BUCKET, add to end
    @buckets[b] = bucket
    bucket << o # add to end
    @nElements += 1
    return o
  end

  def get(o)
    if (o == nil)
      return o
    end
    b = getBucket(o)
    bucket = @buckets[b]
    if (bucket == nil)
      return nil # no bucket
    end
    bucket.each do |e|
      if (e == nil)
        return nil # empty slot not there
      end
      if (@comparator.equals(e, o))
        return e
      end
    end
    return nil
  end

  def getBucket(o)
    hash = @comparator.hash(o)
    b = hash & (@buckets.length - 1) # assumes len is power of 2
    return b
  end


  def hash()
    hash = 0
    @buckets.each do |bucket|
      if (bucket != nil)
        bucket.each do |o|
          if (o == nil)
            break
          end
          hash = MurmurHash.update_int(hash, @comparator.hash(o))
        end
      end
    end

    hash = MurmurHash.finish(hash, size())
    return hash
  end


  def equals(o)
    if (o == self)
      return true
    end
    if (!(o.is_a? Array2DHashSet))
      return false
    end
    other = o
    if (other.size() != size())
      return false
    end
    same = self.containsAll(other)
    return same
  end


  def add(t)
    existing = getOrAdd(t)
    return existing == t
  end


  def size()
    return @nElements
  end


  def isEmpty()
    return @nElements == 0
  end


  def contains(o)
    return containsFast(asElementType(o))
  end

  def containsFast(obj)
    if (obj == nil)
      return false
    end

    return get(obj) != nil
  end


  def iterator()
    a = toArray
    if(@comparator != nil)
      a.sort(@comparator)
    end
    return SetIterator.new(a, self)
  end


  def toArray()
    a = createBucket(size())
    i = 0
    @buckets.each do |bucket|
      if (bucket != nil)
        bucket.each do |o|
          if (o == nil)
            break
          end

          a[i] = o
          i += 1
        end
      end
    end
    return a
  end


  def remove(o)
    return removeFast(asElementType(o))
  end

  def removeFast(obj)
    if (obj == nil)
      return false
    end

    b = getBucket(obj)
    bucket = @buckets[b]
    if (bucket == nil)
      # no bucket
      return false
    end

    i = 0
    while i < bucket.length
      e = bucket[i]
      if (e == nil)
        # empty slot not there
        return false
      end

      if (@comparator.equals(e, obj)) # found it
        bucket[i] = nil
        return true
      end
      i += 1
    end

    return false
  end


  def containsAll(collection)
    if (collection.is_a? Array2DHashSet)
      s = collection
      s.buckets.each do |bucket|
        if (bucket != nil)
          bucket.each do |o|
            if (o == nil)
              break
            end
            if (!containsFast(asElementType(o)))
              return false
            end
          end
        end
      end
    else
      collection.each do |o|
        if (!containsFast(asElementType(o)))
          return false
        end
      end
    end
    return true
  end


  def addAll(c)
    changed = false
    c.each do |o|
      existing = getOrAdd(o)
      if (existing != o)
        changed = true
      end
    end
    return changed
  end


  def retainAll(c)
    newsize = 0
    @buckets.each do |bucket|
      if (bucket != nil)
        i = 0
        j = 0
        while i < bucket.length
          if (bucket[i] == nil)
            break
          end

          if (c.contains(bucket[i]))
            # keep
            if (i != j)
              bucket[j] = bucket[i]
            end

            j += 1
            newsize += 1
          end

          i += 1
        end

        newsize += j

        while (j < i)
          bucket[j] = nil
          j += 1
        end
      end
    end

    changed = newsize != @nElements
    @nElements = newsize
    return changed
  end


  def removeAll(c)
    changed = false
    c.each do |o|
      changed |= removeFast(asElementType(o))
    end

    return changed
  end


  def clear()
    @buckets = createBuckets(INITAL_CAPACITY)
    @nElements = 0
    @threshold = (INITAL_CAPACITY * LOAD_FACTOR).floor
  end


  def to_s()
    if (size() == 0)
      return "{}"
    end

    buf = ""
    buf << '{'
    first = true
    @buckets.each do |bucket|
      if (bucket != nil)
        bucket.each do |o|
          if (o == nil)
            break
          end
          if (first)
            first = false
          else
            buf << ", "
            buf << o.to_s()
          end
        end
      end
    end
    buf << '}'
    return buf
  end

  def toTableString()
    buf = ""
    @buckets.each do |bucket|
      if (bucket == nil)
        buf << "null\n"
      else
        buf << '['
        first = true
        bucket.each do |o|
          if (first)
            first = false
          else
            buf << " "
          end
          if (o == nil)
            buf << "_"
          else
            buf << o.to_s()
          end
        end
        buf << "]\n"
      end
    end
    return buf
  end


  def asElementType(o)
    return o
  end


  def createBuckets(capacity)
    return Array.new(capacity)
  end


  def createBucket(capacity)
    return Array.new(capacity)
  end

  class SetIterator
    def initialize(data, parent)
      @data = data
      @parent = parent
      @nElementsextIndex = 0
      @removed = true
    end


    def hasNext()
      return @nElementsextIndex < @data.length
    end


    def next()
      if (!hasNext())
        raise NoSuchElementException
      end

      @removed = false
      result = @data[@nElementsextIndex]
      @nElementsextIndex += 1
      return result
    end


    def remove()
      if (@removed)
        raise IllegalStateException
      end

      parent.remove(@data[@extIndex - 1])
      @removed = true
    end
  end

  def expand()
    old = @buckets
    @currentPrime += 4
    newCapacity = @buckets.length * 2
    newTable = createBuckets(newCapacity)
    newBucketLengths = Array.new(newTable.length, 0)
    @buckets = newTable
    @threshold = (newCapacity * LOAD_FACTOR).floor

    oldSize = size()
    old.each do |bucket|
      if (bucket != nil)
        bucket.each do |o|
          if (o == nil)
            break
          end

          b = getBucket(o)
          bucketLength = newBucketLengths[b]
          if (bucketLength == 0)
            newBucket = createBucket(@initialBucketCapacity)
            newTable[b] = newBucket
          else
            newBucket = newTable[b]
            if (bucketLength == newBucket.length)
              tmp = Array.new(newBucket.length * 2)
              i = 0
              while (i < newBucket.length)
                tmp[i] = newBucket[i]
                i += 1
              end
              newBucket = tmp
              newTable[b] = newBucket
            end
          end

          newBucket[bucketLength] = o
          newBucketLengths[b] += 1
        end
      end
    end

    if @nElements != oldSize
      raise StandardError, "@nElements != oldSize"
    end
  end

end
