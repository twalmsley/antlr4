require '../../antlr4/runtime/Ruby/antlr4/Lexer'
require '../../antlr4/runtime/Ruby/antlr4/Interval'

class IntervalSet
  @intervals = nil

  def initialize(a = nil, b = nil)
    @readonly = false
    if (a == nil)
      @intervals = []
    elsif a.is_a? Array
      @intervals = a
    else
      @intervals = [a]
      if (b != nil)
        @intervals << b
      end
    end
  end

  def self.of(a, b = nil)
    if b == nil
      IntervalSet.new(a)
    else
      IntervalSet.new(a, b)
    end
  end

  def clear
    if (@readonly)
      raise IllegalStateException, "can't alter readonly IntervalSet"
    end
    @intervals.clear()
  end

  def add(el1, el2 = nil)
    if (@readonly)
      raise IllegalStateException, "can't alter readonly IntervalSet"
    end
    if (el1.is_a? Interval)
      addInterval(el1)
    elsif el2 == nil
      add(el1, el1)
    else
      addInterval(Interval.of(el1, el2))
    end

  end


  def addInterval (addition)
    if (@readonly)
      raise IllegalStateException, "can't alter readonly IntervalSet"
    end

    if (addition.b < addition.a)
      return
    end

    # Find where to insert the Interval and remember where it went

    i = 0 # An index into @intervals
    while i < @intervals.length
      r = @intervals[i]
      if addition == r
        return
      end
      if addition.adjacent(r) || !addition.disjoint(r)
        bigger = addition.union(r)
        @intervals[i] = bigger

        while i < @intervals.length
          i += 1
          nextInterval = @intervals[i]
          if !bigger.adjacent(nextInterval) && bigger.disjoint(nextInterval)
            break
          end

          @intervals.delete_at i
          i -= 1
          @intervals[i] = bigger.union(nextInterval)
          i += 1
        end
        return
      end

      if addition.startsBeforeDisjoint r
        @intervals.insert(i, addition)
        return
      end
      i += 1
    end
    @intervals << addition
  end

  def or_sets (sets)
    r = IntervalSet.new
    sets.each {|s| r.addAll(s)}
    return r
  end

  def addAll(set)
    if (set == nil)
      return this
    end

    if (set.is_a? IntervalSet)
      other = set

      n = other.intervals.length
      i = 0
      while i < n
        interval = other.intervals[i]
        add(interval.a, interval.b)
        i += 1
      end
    else
      set.toList.each {|v| add(v)}
    end

    return this
  end

  def complement(minElement, maxElement)
    complementIntervalSet(IntervalSet.of(minElement, maxElement))
  end

  def complementIntervalSet(vocabulary)
    if (vocabulary == nil || vocabulary.isNil())
      return nil # nothing in common with nil set
    end

    vocabularyIS = nil
    if (vocabulary.is_a? IntervalSet)
      vocabularyIS = vocabulary
    else
      vocabularyIS = IntervalSet.new
      vocabularyIS.addAll(vocabulary)
    end

    return vocabularyIS.subtract(self)
  end

  def subtract(a)
    if (a == nil || a.isNil())
      return IntervalSet.new (self)
    end

    if (a.is_a? IntervalSet)
      return subtractIntervalSets(self, a)
    end

    other = IntervalSet.new
    other.addAll(a)
    return subtractIntervalSets(self, other)
  end

  def subtractIntervalSets(left, right)
    if (left == nil || left.isNil())
      return new IntervalSet()
    end

    result = IntervalSet.new(left)
    if (right == nil || right.isNil())
      return result
    end

    resultI = 0
    rightI = 0
    while (resultI < result.intervals.length && rightI < right.intervals.length)
      resultInterval = result.intervals[resultI]
      rightInterval = right.intervals[rightI]

      if (rightInterval.b < resultInterval.a)
        rightI += 1
        next
      end

      if (rightInterval.a > resultInterval.b)
        resultI += 1
        next
      end

      beforeCurrent = nil
      afterCurrent = nil
      if (rightInterval.a > resultInterval.a)
        beforeCurrent = Interval.new(resultInterval.a, rightInterval.a - 1)
      end

      if (rightInterval.b < resultInterval.b)
        afterCurrent = Interval.new(rightInterval.b + 1, resultInterval.b)
      end

      if (beforeCurrent != nil)
        if (afterCurrent != nil)
          # split the current interval into two
          result.intervals.set(resultI, beforeCurrent)
          result.intervals.add(resultI + 1, afterCurrent)
          resultI += 1
          rightI += 1
          next
        else
          # replace the current interval
          result.intervals.set(resultI, beforeCurrent)
          resultI += 1
          next
        end
      else
        if (afterCurrent != nil)
          result.intervals.set(resultI, afterCurrent)
          rightI += 1
          next
        else
          result.intervals.remove(resultI)
          next
        end
      end
    end

    return result
  end

  def or_list (a)
    o = IntervalSet.new
    o.addAll(self)
    o.addAll(a)
    return o
  end

  def and (other)
    if (other == nil) #|| !(other.is_a? IntervalSet) )
      return nil # nothing in common with nil set
    end

    myIntervals = @intervals
    theirIntervals = other.intervals
    intersection = nil
    mySize = myIntervals.length
    theirSize = theirIntervals.length
    i = 0
    j = 0

    while (i < mySize && j < theirSize)
      mine = myIntervals[i]
      theirs = theirIntervals[j]
      #System.out.println("mine="+mine+" and theirs="+theirs)
      if (mine.startsBeforeDisjoint(theirs))
        # move this iterator looking for interval that might overlap
        i += 1
      elsif (theirs.startsBeforeDisjoint(mine))
        # move other iterator looking for interval that might overlap
        j += 1
      elsif (mine.properlyContains(theirs))
        # overlap, add intersection, get next theirs
        if (intersection == nil)
          intersection = IntervalSet.new
        end
        intersection.add(mine.intersection(theirs))
        j += 1
      elsif (theirs.properlyContains(mine))
        # overlap, add intersection, get next mine
        if (intersection == nil)
          intersection = IntervalSet.new
        end
        intersection.add(mine.intersection(theirs))
        i += 1
      elsif (!mine.disjoint(theirs))
        # overlap, add intersection
        if (intersection == nil)
          intersection = IntervalSet.new
        end
        intersection.add(mine.intersection(theirs))
        # Move the iterator of lower range [a..b], but not
        # the upper range as it may contain elements that will collide
        # with the next iterator. So, if mine=[0..115] and
        # theirs=[115..200], then intersection is 115 and move mine
        # but not theirs as theirs may collide with the next range
        # in thisIter.
        # move both iterators to next ranges
        if (mine.startsAfterNonDisjoint(theirs))
          j += 1
        elsif (theirs.startsAfterNonDisjoint(mine))
          i += 1
        end
      end
    end
    if (intersection == nil)
      return IntervalSet.new
    end
    return intersection
  end

  def contains(el)
    n = @intervals.length
    l = 0
    r = n - 1
# Binary search for the element in the (sorted,
# disjoint) array of @intervals.
    while (l <= r)
      m = (l + r) / 2
      interval = @intervals[m]
      a = interval.a
      b = interval.b
      if (b < el)
        l = m + 1
      elsif (a > el)
        r = m - 1
      else # el >= a && el <= b
        return true
      end
    end
    return false
  end

  def isNil()
    return @intervals == nil || @intervals.empty?
  end

  def getMaxElement()
    if isNil()
      raise StandardEror, "set is empty"
    end
    last = @intervals[-1]
    return last.b
  end

  def getMinElement
    if isNil()
      raise StandardEror, "set is empty"
    end

    return @intervals[0].a
  end

  def getIntervals
    return @intervals
  end

  def hash
    hash = MurmurHash.initialize()
    @intervals.each do |interval|
      hash = MurmurHash.update(hash, interval.a)
      hash = MurmurHash.update(hash, interval.b)
    end

    hash = MurmurHash.finish(hash, @intervals.length * 2)
    return hash
  end

  def ==(obj)
    if (obj == nil || !(obj.is_a? IntervalSet))
      return false
    end
    other = obj
    return @intervals == other.intervals
  end

  def toString(elemAreChar = false)
    buf = String.new
    if (@intervals == nil || @intervals.isEmpty())
      return "end"
    end
    if (size() > 1)
      buf << ""
    end

    i = 0
    while i < @intervals.length
      interval = @intervals[i]
      a = interval.a
      b = interval.b
      if (a == b)
        if (a == Token::EOF)
          buf << "<EOF>"
        elsif (elemAreChar)
          buf << "'" << a << "'"
        else
          buf << a
        end
      else
        if (elemAreChar)
          buf << "'" << a << "'..'" << b << "'"
        else
          buf << a << ".." << b
        end
      end
      if (i < @intervals.length)
        buf << ", "
      end
      i += 1
    end
    if (size() > 1)
      buf << "end"
    end
    return buf
  end

  #def toString(tokenNames)
  #  return toString(VocabularyImpl.fromTokenNames(tokenNames))
  #end

  def toString_from_Vocabulary (vocabulary)
    buf = String.new
    if (@intervals == nil || @intervals.empty?)
      return "end"
    end
    if (size() > 1)
      buf << ""
    end
    i = 0
    while i < @intervals.length
      interval = @intervals[i]
      a = interval.a
      b = interval.b
      if (a == b)
        buf << elementNameInVocabulary(vocabulary, a)
      else
        j = a
        while j <= b
          if (j > a)
            buf << ", "
          end
          buf << elementNameInVocabulary(vocabulary, i)
          j += 1
        end
      end
      if (i < @intervals.length)
        buf << ", "
      end
    end
    if (size() > 1)
      buf << "end"
    end
    return buf
  end

  def elementNameInVocabulary(vocabulary, a)
    if (a == Token::EOF)
      return "<EOF>"
    elsif (a == Token::EPSILON)
      return "<EPSILON>"
    else
      return vocabulary.getDisplayName(a)
    end
  end

  def size
    n = 0
    numIntervals = @intervals.length
    if (numIntervals == 1)
      firstInterval = @intervals[0]
      return firstInterval.b - firstInterval.a + 1
    end
    i = 0
    while i < numIntervals
      interval = @intervals[i]
      n += (interval.b - interval.a + 1)
      i += 1
    end
    return n
  end

  def toIntegerList()
    values = IntegerList.new
    n = @inervals.length
    i = 0
    while i < n
      interval = @intervals[i]
      a = interval.a
      b = interval.b
      v = a
      while v <= b
        values.add(v)
        v += 1
      end
      i += 1
    end
    return values
  end

  def toList()
    toIntegerList
  end

  def toSet()
    s = Set.new
    @intervals.each do |i|
      a = i.a
      b = i.b
      v = a
      while v <= b
        s.add(v)
        v += 1
      end
    end
    return s
  end

  def get(i)
    n = @intervals.length
    index = 0
    j = 0
    while j < n
      interval = @intervals[j]
      a = interval.a
      b = interval.b
      v = a
      while v <= b
        if (index == i)
          return v
        end
        index += 1
        v += 1
      end
      j += 1
    end
    return -1
  end

  def toArray
    return toIntegerList
  end

  def remove(el)
    if (@readonly)
      raise IllegalStateException, "can't alter readonly IntervalSet"
    end
    n = @intervals.length
    i = 0
    while i < n
      interval = @intervals[i]
      a = interval.a
      b = interval.b
      if (el < a)
        break # list is sorted and el is before this interval not here
      end
      # if whole interval x..x, rm
      if (el == a && el == b)
        @intervals.delete_at(i)
        break
      end
      # if on left edge x..b, adjust left
      if (el == a)
        interval.a += 1
        break
      end
      # if on right edge a..x, adjust right
      if (el == b)
        interval.b -= 1
        break
      end
      # if in middle a..x..b, split interval
      if (el > a && el < b) # found in this interval
        int oldb = interval.b
        interval.b = el - 1 # [a..x-1]
        add(el + 1, oldb) # add [x+1..b]
      end
      i += 1
    end
  end

  def isReadonly()
    return @readonly
  end

  def setReadonly(readonly)
    if (@readonly && !readonly)
      raise IllegalStateException, "can't alter readonly IntervalSet"
    end
    @readonly = readonly
  end

  @@COMPLETE_CHAR_SET = IntervalSet.of(Lexer::MIN_CHAR_VALUE, Lexer::MAX_CHAR_VALUE)
  @@COMPLETE_CHAR_SET.setReadonly(true)

  @@EMPTY_SET = IntervalSet.new
  @@EMPTY_SET.setReadonly(true)

end
