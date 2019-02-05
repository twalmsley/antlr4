require '../../antlr4/runtime/Ruby/antlr4/TokenStream'

class BufferedTokenStream < TokenStream


  @tokenSource = nil


  @tokens = []


  @p = -1


  @fetchedEOF = false

  def initialize(tokenSource)
    if (tokenSource == nil)
      raise nilPointerException, "tokenSource cannot be nil"
    end
    @tokenSource = tokenSource
  end


  def getTokenSource()
    return @tokenSource
  end


  def index()
    return @p
  end


  def mark()
    return 0
  end


  def release(marker)
# no resources to release
  end


  def reset()
    seek(0)
  end


  def seek(index)
    lazyInit()
    @p = adjustSeekIndex(index)
  end


  def size()
    return tokens.size()
  end


  def consume()
    skipEofCheck = false
    if (@p >= 0)
      if (@fetchedEOF)
        # the last token in tokens is EOF. skip check if p indexes any
        # fetched token except the last.
        skipEofCheck = @p < @tokens.size() - 1
      else
        # no EOF token in tokens. skip check if p indexes a fetched token.
        skipEofCheck = @p < @tokens.size()
      end
    else
# not yet initialized
      skipEofCheck = false
    end

    if (!skipEofCheck && LA(1) == EOF)
      raise IllegalStateException, "cannot consume EOF"
    end

    if (sync(@p + 1))
      @p = adjustSeekIndex(@p + 1)
    end
  end


  def sync(i)
    n = i - @tokens.size() + 1 # how many more elements we need?

    if (n > 0)
      fetched = fetch(n)
      return fetched >= n
    end

    return true
  end


  def fetch(n)
    if (@fetchedEOF)
      return 0
    end

    i = 0
    while i < n
      t = @tokenSource.nextToken()
      if (t.is_a? WritableToken)
        t.setTokenIndex(@tokens.size())
      end
      tokens.add(t)
      if (t.getType() == Token.EOF)
        @fetchedEOF = true
        return i + 1
      end
      i += 1
    end

    return n
  end


  def get(i)
    if (i < 0 || i >= @tokens.size())
      raise IndexOutOfBoundsException, "token index " + i + " out of range 0.." + (@tokens.size() - 1)
    end
    return @tokens.get(i)
  end


  def get_list(start, stop)
    if (start < 0 || stop < 0)
      return nil
    end
    lazyInit()
    subset = []
    if (stop >= @tokens.size())
      stop = @tokens.size() - 1
    end
    i = start
    while i <= stop
      t = @tokens.get(i)
      if (t.getType() == Token.EOF)
        break
      end
      subset.add(t)
      i += 1
    end
    return subset
  end


  def LA(i)
    return LT(i).getType()
  end

  def LB(k)
    if ((@p - k) < 0)
      return nil
    end
    return @tokens.get(@p - k)
  end


  def LT(k)
    lazyInit()
    if (k == 0)
      return nil
    end

    if (k < 0)
      return LB(-k)
    end

    i = @p + k - 1
    sync(i)
    if (i >= @tokens.size()) # return EOF token
      # EOF must be last token
      return @tokens.get(@tokens.size() - 1)
    end
#		if ( i>range ) range = i
    return @tokens.get(i)
  end


  def adjustSeekIndex(i)
    return i
  end

  def lazyInit()
    if (@p == -1)
      setup()
    end
  end

  def setup()
    sync(0)
    @p = adjustSeekIndex(0)
  end


  def setTokenSource(tokenSource)
    @tokenSource = tokenSource
    @tokens.clear()
    @p = -1
    @fetchedEOF = false
  end

  def getTokens()
    return @tokens
  end


  def getTokens_1(start, stop, types = nil)
    lazyInit()
    if (start < 0 || stop >= @tokens.size() ||
        stop < 0 || start >= @tokens.size())

      raise IndexOutOfBoundsException, "start " + start + " or stop " + stop +
          " not in 0.." + (@tokens.size() - 1)
    end
    if (start > stop)
      return nil
    end

    # list = tokens[start:stop]:T t, t.getType() in typesend
    filteredTokens = []
    i = start
    while i <= stop
      t = @tokens.get(i)
      if (types == nil || types.include?(t.getType()))
        filteredTokens.add(t)
      end
      i += 1
    end
    if (filteredTokens.empty?())
      filteredTokens = nil
    end
    return filteredTokens
  end

  def getTokens_2(start, stop, ttype)
    s = Set.new
    s.add(ttype)
    return getTokens_1(start, stop, s)
  end


  def nextTokenOnChannel(i, channel)
    sync(i)
    if (i >= size())
      return size() - 1
    end

    token = @tokens.get(i)
    while (token.getChannel() != channel)
      if (token.getType() == Token.EOF)
        return i
      end

      i += 1
      sync(i)
      token = @tokens.get(i)
    end

    return i
  end


  def previousTokenOnChannel(i, channel)
    sync(i)
    if (i >= size())
      # the EOF token is on every channel
      return size() - 1
    end

    while (i >= 0)
      token = @tokens.get(i)
      if (token.getType() == Token.EOF || token.getChannel() == channel)
        return i
      end

      i -= 1
    end

    return i
  end


  def getHiddenTokensToRight(tokenIndex, channel)
    lazyInit()
    if (tokenIndex < 0 || tokenIndex >= tokens.size())
      raise IndexOutOfBoundsException, tokenIndex + " not in 0.." + (@tokens.size() - 1)
    end

    nextOnChannel =
        nextTokenOnChannel(tokenIndex + 1, Lexer.DEFAULT_TOKEN_CHANNEL)
    to = 0
    from = tokenIndex + 1
# if none onchannel to right, nextOnChannel=-1 so set to = last token
    if (nextOnChannel == -1)
      to = size() - 1
    else
      to = nextOnChannel
    end

    return filterForChannel(from, to, channel)
  end


  def getHiddenTokensToRight_2(tokenIndex)
    return getHiddenTokensToRight(tokenIndex, -1)
  end


  def getHiddenTokensToLeft(tokenIndex, channel)
    lazyInit()
    if (tokenIndex < 0 || tokenIndex >= tokens.size())
      raise IndexOutOfBoundsException, tokenIndex + " not in 0.." + (@tokens.size() - 1)
    end

    if (tokenIndex == 0)
      # obviously no tokens can appear before the first token
      return nil
    end

    prevOnChannel =
        previousTokenOnChannel(tokenIndex - 1, Lexer.DEFAULT_TOKEN_CHANNEL)
    if (prevOnChannel == tokenIndex - 1)
      return nil
    end
    # if none onchannel to left, prevOnChannel=-1 then from=0
    from = prevOnChannel + 1
    to = tokenIndex - 1

    return filterForChannel(from, to, channel)
  end


  def getHiddenTokensToLeft_1(tokenIndex)
    return getHiddenTokensToLeft(tokenIndex, -1)
  end

  def filterForChannel(from, to, channel)
    hidden = []
    i = from
    while i <= to
      t = @tokens.get(i)
      if (channel == -1)
        if (t.getChannel() != Lexer.DEFAULT_TOKEN_CHANNEL)
          hidden.add(t)
        end
      else
        if (t.getChannel() == channel)
          hidden.add(t)
        end
      end
      i += 1
    end
    if (hidden.size() == 0)
      return nil
    end
    return hidden
  end


  def getSourceName()
    return @tokenSource.getSourceName()
  end


  def getText()
    return getText_2(Interval.of(0, size() - 1))
  end


  def getText_2(interval)
    start = interval.a
    stop = interval.b
    if (start < 0 || stop < 0)
      return ""
    end
    fill()
    if (stop >= @tokens.size())
      stop = @tokens.size() - 1
    end

    buf = ""
    i = start
    while i <= stop
      t = @tokens.get(i)
      if (t.getType() == Token.EOF)
        break
      end
      buf << t.getText()
      i += 1
    end
    return buf.to_s()
  end


  def getText_3(ctx)
    return getText_2(ctx.getSourceInterval())
  end


  def getText_4(start, stop)
    if (start != nil && stop != nil)
      return getText_2(Interval.of(start.getTokenIndex(), stop.getTokenIndex()))
    end

    return ""
  end


  def fill()
    lazyInit()
    blockSize = 1000
    while (true)
      fetched = fetch(blockSize)
      if (fetched < blockSize)
        return
      end
    end
  end
end
