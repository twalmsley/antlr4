require '../../antlr4/runtime/Ruby/antlr4/BufferedTokenStream'
require '../../antlr4/runtime/Ruby/antlr4/Token'

class CommonTokenStream < BufferedTokenStream


  @channel = Token::DEFAULT_CHANNEL


  def initialize(tokenSource, channel = nil)
    super(tokenSource)
    if channel != nil
      @channel = channel
    end
  end


  def adjustSeekIndex(i)
    return nextTokenOnChannel(i, @channel)
  end


  def LB(k)
    if (k == 0 || (@p - k) < 0)
      return nil
    end

    i = @p
    n = 1
    # find k good tokens looking backwards
    while (n <= k && i > 0)
      # skip off-channel tokens
      i = previousTokenOnChannel(i - 1, @channel)
      n += 1
    end
    if (i < 0)
      return nil
    end
    return @tokens.get(i)
  end


  def LT(k)
    lazyInit()
    if (k == 0)
      return nil
    end
    if (k < 0)
      return LB(-k)
    end
    i = p
    n = 1 # we know tokens[p] is a good one
    # find k good tokens
    while (n < k)
      # skip off-channel tokens, but make sure to not look past EOF
      if (sync(i + 1))
        i = nextTokenOnChannel(i + 1, @channel)
      end
      n += 1
    end
    #		if ( i>range ) range = i
    return @tokens[i]
  end


  def getNumberOfOnChannelTokens()
    n = 0
    fill()
    i = 0
    while i < @tokens.size()
      t = @tokens.get(i)
      if (t.getChannel() == @channel)
        n += 1
      end
      if (t.getType() == Token.EOF)
        break
      end
      i += 1
    end
    return n
  end
end
