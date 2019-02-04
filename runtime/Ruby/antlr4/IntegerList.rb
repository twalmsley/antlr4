require '../../antlr4/runtime/Ruby/antlr4/Integer'

class IntegerList

  @@EMPTY_DATA = []

  @@INITIAL_SIZE = 4
  @@MAX_ARRAY_SIZE = Integer::MAX - 8


  attr_reader :_data
  @_data = []

  attr_reader :_size
  @_size = 0


  def initialize(list = nil)
    if list != nil
      @_data = Array.new(list._data)
      @_size = list._size
    end
  end

  def add(value)

    @_data[@_size] = value
    @_size += 1
  end

  def addAll(array)
    @_data = @_data + array
    @_size = @_data.length
  end


  def get(index)
    if (index < 0 || index >= @_size)
      raise IndexOutOfBoundsException
    end

    return @_data[index]
  end

  def contains(value)
    @_data.include?(value)
  end

  def set(index, value)
    if (index < 0 || index >= @_size)
      raise IndexOutOfBoundsException
    end

    previous = @_data[index]
    @_data[index] = value
    return previous
  end

  def removeAt(index)
    value = get(index)
    @_data.delete_at(index)
    @_size = @_data.length
    return value
  end

  def isEmpty()
    return @_size == 0
  end

  def size()
    return @_size
  end

  def clear()
    @_data.clear
    _size = 0
  end

  def toArray()
    if (@_size == 0)
      return @@EMPTY_DATA
    end

    return Array.new(@_data)
  end

  def sort()
    @_data.sort!
  end


  def equals(o)
    if (o == this)
      return true
    end

    if (!(o.is_a? IntegerList))
      return false
    end

    other = o
    if (@_size != other._size)
      return false
    end

    i = 0
    while i < _size
      if (@_data[i] != other._data[i])
        return false
      end
      i += 1
    end

    return true
  end


  def hash()
    hashCode = 1
    i = 0
    while i < @_size
      hashCode = 31 * hashCode + @_data[i]
      i += 1
    end

    return hashCode
  end


  def to_s()
    @_data.to_s
  end

  def binarySearch(key)
    @_data.bsearch {|x| x - key}
  end

end
