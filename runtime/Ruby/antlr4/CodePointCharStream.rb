require '../../antlr4/runtime/Ruby/antlr4/CharStream'
require '../../antlr4/runtime/Ruby/antlr4/Integer'

class CodePointCharStream < CharStream

  def initialize(position, remaining, name, byteArray)
    @size = remaining
    @name = name
    @position = position
    @byteArray = byteArray
  end


  def getText(interval)
    startIdx = [interval.a, @size].min
    len = [interval.b - interval.a + 1, @size - startIdx].min

# We know the maximum code point in byteArray is U+00FF,
# so we can treat this as if it were ISO-8859-1, aka Latin-1,
# which shares the same code points up to 0xFF.
    return @byteArray.slice(startIdx, len).join
  end


  def LA(i)
    case (Integer.signum(i))
    when -1
      offset = @position + i
      if (offset < 0)
        return IntStream::EOF
      end
      return @byteArray[offset] & 0xFF
    when 0
# Undefined
      return 0
    when 1
      offset = @position + i - 1
      if (offset >= @size)
        return IntStream::EOF
      end
      return @byteArray[offset] & 0xFF
    end
    raise UnsupportedOperationException, "Not reached"
  end


  def getInternalStorage()
    return @byteArray
  end

  def consume()
    if (@size - @position == 0)
      raise IllegalStateException, "cannot consume EOF"
    end
    @position = @position + 1
  end


  def index()
    return @position
  end


  def size()
    return @size
  end

  def mark()
    return -1
  end


  def release(marker)
  end


  def seek(index)
    @position = index
  end


  def getSourceName()
    if (@name == nil || @name.empty?)
      return UNKNOWN_SOURCE_NAME
    end

    return @name
  end

end
