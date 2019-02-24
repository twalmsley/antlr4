require 'weakref'
require '../antlr4/ConsoleErrorListener'
require '../antlr4/ProxyErrorListener'

class Recognizer

  EOF = -1

  def initialize
    @tokenTypeMapCache = []
    @ruleIndexMapCache = []
    @_listeners = []
    @_listeners << ConsoleErrorListener.instance
    @_interp = nil
    @_stateNumber = -1
  end

  def getVocabulary()
    return VocabularyImpl.fromTokenNames(getTokenNames())
  end

  def getTokenNames()
    return nil
  end

  def getTokenTypeMap()
    vocabulary = getVocabulary()
    result = @tokenTypeMapCache[vocabulary]
    if (result == nil)
      result = Hash.new
      i = 0
      while i <= getATN().maxTokenType
        literalName = vocabulary.getLiteralName(i)
        if (literalName != nil)
          result[literalName] = i
        end

        symbolicName = vocabulary.getSymbolicName(i)
        if (symbolicName != nil)
          result[symbolicName] = i
        end
        i += 1
      end

      result["EOF"] = Token::EOF
      @tokenTypeMapCache[vocabulary] = result
    end

    return result
  end


  def getRuleIndexMap()
    ruleNames = getRuleNames()
    if (ruleNames == nil)
      raise UnsupportedOperationException, "The current recognizer does not provide a list of rule names."
    end

    result = @ruleIndexMapCache[ruleNames]
    if (result == nil)
      result = Utils.toMap(ruleNames)
      @ruleIndexMapCache[ruleNames] = result
    end

    return result
  end

  def getTokenType(tokenName)
    ttype = getTokenTypeMap()[tokenName]
    if (ttype != nil)
      return ttype
    end
    return Token::INVALID_TYPE
  end


  def getSerializedATN()
    raise UnsupportedOperationException, "there is no serialized ATN"
  end


  def getInterpreter()
    return @_interp
  end


  def getParseInfo()
    return nil
  end


  def setInterpreter(interpreter)
    @_interp = interpreter
  end


  def getErrorHeader(e)
    line = e.getOffendingToken().getLine()
    charPositionInLine = e.getOffendingToken().getCharPositionInLine()
    return "line " + line + ":" + charPositionInLine
  end


  def getTokenErrorDisplay(t)
    if (t == nil)
      return "<no token>"
    end
    s = t.getText()
    if (s == nil)
      if (t.getType() == Token::EOF)
        s = "<EOF>"
      else
        s = "<" + t.getType() + ">"
      end
    end
    s = s.tr_s!("\n", "\\n")
    s = s.tr_s!("\r", "\\r")
    s = s.tr_s!("\t", "\\t")
    return "'" + s + "'"
  end


  def addErrorListener(listener)
    if (listener == nil)
      raise NullPointerException, "listener cannot be nil."
    end

    @_listeners << listener
  end

  def removeErrorListener(listener)
    @_listeners.delete(listener)
  end

  def removeErrorListeners()
    @_listeners.clear()
  end


  def getErrorListeners()
    @_listeners
  end

  def getErrorListenerDispatch()
    return ProxyErrorListener.new(@_listeners)
  end

# subclass needs to override these if there are sempreds or actions
# that the ATN interp needs to execute
  def sempred(_localctx, ruleIndex, actionIndex)
    return true
  end

  def precpred(localctx, precedence)
    return true
  end

  def action(_localctx, ruleIndex, actionIndex)
  end

  def getState()
    return @_stateNumber
  end


  def setState(atnState)
    @_stateNumber = atnState
  end

end
