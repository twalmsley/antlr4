require '../../antlr4/runtime/Ruby/antlr4/CharStream'

class CodePointCharStream < CharStream

  def initialize(position, remaining, name, byteArray)
    @size = remaining
    @name = name
    @position = position
    @byteArray = byteArray
  end


  def getText(interval)
    startIdx = [interval.a, @size].min
    len = [interval.b - interval.a + 1, size - startIdx].min

# We know the maximum code point in byteArray is U+00FF,
# so we can treat this as if it were ISO-8859-1, aka Latin-1,
# which shares the same code points up to 0xFF.
    return String.new(@byteArray, startIdx, len)
  end


  def LA(i)
    case (Integer.signum(i))
    when -1
      offset = @position + i
      if (offset < 0)
        return IntStream.EOF
      end
      return @byteArray[offset] & 0xFF
    when 0
# Undefined
      return 0
    when 1
      offset = @position + i - 1
      if (offset >= @size)
        return IntStream.EOF
      end
      return @byteArray[offset] & 0xFF
    end
    raise UnsupportedOperationException, "Not reached"
  end


  def getInternalStorage()
    return @byteArray
  end
end
