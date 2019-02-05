require '../../antlr4/runtime/Ruby/antlr4/Recognizer'
require '../../antlr4/runtime/Ruby/antlr4/Token'
require '../../antlr4/runtime/Ruby/antlr4/CommonTokenFactory'
require '../../antlr4/runtime/Ruby/antlr4/IntegerStack'

class Lexer < Recognizer

  DEFAULT_MODE = 0
  MORE = -2
  SKIP = -3

  DEFAULT_TOKEN_CHANNEL = Token::DEFAULT_CHANNEL
  HIDDEN = Token::HIDDEN_CHANNEL
  MIN_CHAR_VALUE = 0x0000
  MAX_CHAR_VALUE = 0x10FFFF

  attr_accessor :_input
  @_input = nil

  @_tokenFactorySourcePair = nil


  @_factory = CommonTokenFactory::DEFAULT


  attr_accessor :token
  @_token = nil


  attr_accessor :_tokenStartCharIndex
  @_tokenStartCharIndex = -1


  attr_accessor :_tokenStartLine


  attr_accessor :_tokenStartCharPositionInLine


  attr_accessor :_hitEOF


  attr_accessor :_channel


  attr_accessor :_type

  attr_accessor :_modeStack
  @_modeStack = IntegerStack.new

  attr_accessor :_mode
  @_mode = DEFAULT_MODE


  attr_accessor :_text


  def initialize(input = nil)
    if input != nil
      @_input = input
      @_tokenFactorySourcePair = OpenStruct.new
      @_tokenFactorySourcePair.a = self
      @_tokenFactorySourcePair.b = input
    end
  end

  def reset
# wack Lexer state variables
    if (@_input != nil)
      @_input.seek(0) # rewind the input
    end
    @_token = nil
    @_type = Token.INVALID_TYPE
    @_channel = Token.DEFAULT_CHANNEL
    @_tokenStartCharIndex = -1
    @_tokenStartCharPositionInLine = -1
    @_tokenStartLine = -1
    @_text = nil

    @_hitEOF = false
    @_mode = Lexer.DEFAULT_MODE
    @_modeStack.clear()

    getInterpreter().reset()
  end


  def nextToken
    if (@_input == nil)
      raise IllegalStateException, "nextToken requires a non-nil input stream."
    end

# Mark start location in char stream so unbuffered streams are
# guaranteed at least have text of current token
    tokenStartMarker = @_input.mark()
    begin

      repeatOuter = true
      while repeatOuter
        repeatOuter = nextTokenInner
      end
      return @_token

    ensure
# make sure we release marker after match or
# unbuffered char stream will keep buffering
      @_input.release(tokenStartMarker)
    end
  end

  def nextTokenInner
    while (true)
      if (@_hitEOF)
        emitEOF()
        return false
      end

      @_token = nil
      @_channel = Token.DEFAULT_CHANNEL
      @_tokenStartCharIndex = @_input.index()
      @_tokenStartCharPositionInLine = getInterpreter().getCharPositionInLine()
      @_tokenStartLine = getInterpreter().getLine()
      @_text = nil
      loop do
        @_type = Token.INVALID_TYPE

        ttype = 0
        begin
          ttype = getInterpreter().match(@_input, _mode)
        rescue LexerNoViableAltException => e
          notifyListeners(e) # report error
          recover(e)
          ttype = SKIP
        end
        if (@_input.LA(1) == IntStream.EOF)
          @_hitEOF = true
        end
        if (_type == Token.INVALID_TYPE)
          @_type = ttype
        end
        if (@_type == SKIP)
          return true
        end
        break if @_type != MORE
      end

      if (@_token == nil)
        emit()
        return false
      end
    end
  end


  def skip
    @_type = SKIP
  end

  def more()
    @_type = MORE
  end

  def mode(m)
    @_mode = m
  end

  def pushMode(m)
    if (LexerATNSimulator.debug)
      puts("pushMode " + m)
    end
    @_modeStack.push(@_mode)
    mode(m)
  end

  def popMode()
    if @_modeStack.empty?
      raise EmptyStackException
    end
    if (LexerATNSimulator.debug)
      puts("popMode back to " + @_modeStack[-1])
    end
    mode(@_modeStack.pop())
    return @_mode
  end


  def setTokenFactory(factory)
    @_factory = factory
  end


  def getTokenFactory()
    @_factory
  end


  def setInputStream(input)
    @_input = nil
    @_tokenFactorySourcePair = OpenStruct.new
    @_tokenFactorySourcePair.a = self
    @_tokenFactorySourcePair.b = @_input
    reset()
    @_input = input
    @_tokenFactorySourcePair.a = self
    @_tokenFactorySourcePair.b = @_input
  end


  def getSourceName()
    return @_input.getSourceName()
  end


  def getInputStream()
    return @_input
  end

  def emit(token = nil)
    if token != nil
      @_token = token
    else
      t = @_factory.create(@_tokenFactorySourcePair, @_type, @_text, @_channel, @_tokenStartCharIndex, getCharIndex() - 1,
                           @_tokenStartLine, @_tokenStartCharPositionInLine)
      @_token = token
    end
    return t
  end

  def emitEOF
    cpos = getCharPositionInLine()
    line = getLine()
    eof = @_factory.create(@_tokenFactorySourcePair, Token.EOF, nil, Token.DEFAULT_CHANNEL, @_input.index(), @_input.index() - 1,
                           line, cpos)
    emit(eof)
    return eof
  end


  def getLine()
    return getInterpreter().getLine()
  end


  def getCharPositionInLine()
    return getInterpreter().getCharPositionInLine()
  end

  def setLine(line)
    getInterpreter().setLine(line)
  end

  def setCharPositionInLine(charPositionInLine)
    getInterpreter().setCharPositionInLine(charPositionInLine)
  end


  def getCharIndex()
    return @_input.index()
  end


  def getText()
    if (@_text != nil)
      return _text
    end
    return getInterpreter().getText(@_input)
  end


  def setText(text)
    @_text = text
  end


  def getToken()
    return @_token
  end

  def setToken(_token)
    @_token = _token
  end

  def setType(ttype)
    @_type = ttype
  end

  def getType()
    return @_type
  end

  def setChannel(channel)
    @_channel = channel
  end

  def getChannel()
    return @_channel
  end

  def getChannelNames()
    return nil
  end

  def getModeNames()
    return nil
  end


  def getTokenNames()
    return nil
  end


  def getAllTokens()
    tokens = []
    t = nextToken()
    while (t.getType() != Token.EOF)
      tokens << t
      t = nextToken()
    end
    return tokens
  end

  def recover_1(e)
    if (@_input.LA(1) != IntStream.EOF)
      # skip a char and begin again
      getInterpreter().consume(@_input)
    end
  end

  def notifyListeners(e)
    text = @_input.getText(Interval.of(@_tokenStartCharIndex, @_input.index()))
    msg = "token recognition error at: '" + getErrorDisplay(text) + "'"

    listener = getErrorListenerDispatch()
    listener.syntaxError(self, nil, @_tokenStartLine, @_tokenStartCharPositionInLine, msg, e)
  end

  def getErrorDisplay(s)
    buf = String.new
    s.chars.each do |c|
      buf << getErrorDisplayChar(c)
    end
    return buf
  end

  def getErrorDisplayChar(c)
    s = ""
    s << c
    case (c)
    when Token.EOF
      s = "<EOF>"
    when '\n'
      s = "\\n"
    when '\t'
      s = "\\t"
    when '\r'
      s = "\\r"
    end
    return s
  end

  def getCharErrorDisplay(c)
    s = getErrorDisplayChar(c)
    return "'" + s + "'"
  end


  def recover_2(re)
    @_input.consume()
  end
end
