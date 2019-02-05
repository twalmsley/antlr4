require '../../antlr4/runtime/Ruby/antlr4/Recognizer'
require '../../antlr4/runtime/Ruby/antlr4/ParseTreeListener'
require '../../antlr4/runtime/Ruby/antlr4/DefaultErrorStrategy'
require '../../antlr4/runtime/Ruby/antlr4/ATNDeserializer'
require '../../antlr4/runtime/Ruby/antlr4/VocabularyImpl'
require '../../antlr4/runtime/Ruby/antlr4/IntegerStack'

class Parser < Recognizer

  class TraceListener < ParseTreeListener

    def enterEveryRule(ctx)
      puts("enter   " + getRuleNames()[ctx.getRuleIndex()] +
               ", LT(1)=" + @_input.LT(1).getText())
    end


    def visitTerminal(node)
      puts("consume " + node.getSymbol() + " rule " +
               getRuleNames()[_ctx.getRuleIndex()])
    end


    def visitErrorNode(node)
    end

    def exitEveryRule(ctx)
      puts("exit    " + getRuleNames()[ctx.getRuleIndex()] +
               ", LT(1)=" + @_input.LT(1).getText())
    end
  end

  class TrimToSizeListener < ParseTreeListener
    INSTANCE = TrimToSizeListener.new()


    def enterEveryRule(ctx)
    end


    def visitTerminal(node)
    end


    def visitErrorNode(node)
    end


    def exitEveryRule(ctx)
      if (ctx.children.is_a? ArrayList)
        ctx.children.trimToSize()
      end
    end
  end


  @@bypassAltsAtnCache = Hash.new

  @_errHandler = DefaultErrorStrategy.new()


  @_input = nil

  @_precedenceStack = IntegerStack.new()
  @_precedenceStack.push(0)


  @_ctx = nil


  @_buildParseTrees = true


  @_tracer = nil


  @_parseListeners = nil


  @_syntaxErrors = nil


  @matchedEOF = nil

  def initialize(input)
    setInputStream(input)
  end


  def reset()
    if (getInputStream() != nil)
      getInputStream().seek(0)
    end
    @_errHandler.reset(self)
    @_ctx = nil
    @_syntaxErrors = 0
    @matchedEOF = false
    setTrace(false)
    @_precedenceStack.clear()
    @_precedenceStack.push(0)
    interpreter = getInterpreter()
    if (interpreter != nil)
      interpreter.reset()
    end
  end


  def match(ttype)
    t = getCurrentToken()
    if (t.getType() == ttype)
      if (ttype == Token.EOF)
        @matchedEOF = true
      end
      @_errHandler.reportMatch(this)
      consume()
    else
      t = @_errHandler.recoverInline(this)
      if (@_buildParseTrees && t.getTokenIndex() == -1)
        # we must have conjured up a new token during single token insertion
        # if it's not the current symbol
        @_ctx.addErrorNode(createErrorNode(@_ctx, t))
      end
    end

    return t
  end


  def matchWildcard()
    t = getCurrentToken()
    if (t.getType() > 0)
      @_errHandler.reportMatch(this)
      consume()
    else
      t = @_errHandler.recoverInline(this)
      if (@_buildParseTrees && t.getTokenIndex() == -1)
        # we must have conjured up a new token during single token insertion
        # if it's not the current symbol
        @_ctx.addErrorNode(createErrorNode(@_ctx, t))
      end
    end

    return t
  end


  def setBuildParseTree(buildParseTrees)
    @_buildParseTrees = buildParseTrees
  end


  def getBuildParseTree()
    return @_buildParseTrees
  end


  def setTrimParseTree(trimParseTrees)
    if (trimParseTrees)
      if (getTrimParseTree())
        return
      end
      addParseListener(TrimToSizeListener.INSTANCE)
    else
      removeParseListener(TrimToSizeListener.INSTANCE)
    end
  end


  def getTrimParseTree()
    return getParseListeners().contains(TrimToSizeListener.INSTANCE)
  end


  def getParseListeners()
    listeners = @_parseListeners
    if (listeners == nil)
      return []
    end

    return listeners
  end


  def addParseListener(listener)
    if (listener == nil)
      raise nilPointerException, "listener"
    end

    if (@_parseListeners == nil)
      @_parseListeners = []
    end

    @_parseListeners.add(listener)
  end


  def removeParseListener(listener)
    if (@_parseListeners != nil)
      if (@_parseListeners.remove(listener))
        if (@_parseListeners.isEmpty())
          @_parseListeners = nil
        end
      end
    end
  end


  def removeParseListeners()
    _parseListeners = nil
  end


  def triggerEnterRuleEvent()
    @_parseListeners.each do |listener|
      listener.enterEveryRule(@_ctx)
      @_ctx.enterRule(listener)
    end
  end


  def triggerExitRuleEvent()
# reverse order walk of listeners
    i = @_parseListeners.length - 1
    while i >= 0

      listener = @_parseListeners[i]
      @_ctx.exitRule(listener)
      listener.exitEveryRule(@_ctx)
      i += 1
    end
  end


  def getNumberOfSyntaxErrors()
    return @_syntaxErrors
  end


  def getTokenFactory()
    return @_input.getTokenSource().getTokenFactory()
  end


  def setTokenFactory(factory)
    @_input.getTokenSource().setTokenFactory(factory)
  end


  def getATNWithBypassAlts()
    serializedAtn = getSerializedATN()
    if (serializedAtn == nil)
      raise UnsupportedOperationException, "The current parser does not support an ATN with bypass alternatives."
    end

    result = bypassAltsAtnCache.get(serializedAtn)
    if (result == nil)
      deserializationOptions = ATNDeserializationOptions.new
      deserializationOptions.setGenerateRuleBypassTransitions(true)
      result = ATNDeserializer.new(deserializationOptions).deserialize(serializedAtn)
      bypassAltsAtnCache.put(serializedAtn, result)
    end

    return result
  end


  def compileParseTreePattern_1(pattern, patternRuleIndex)
    if (getTokenStream() != nil)
      tokenSource = getTokenStream().getTokenSource()
      if (tokenSource.is_a? Lexer)
        lexer = tokenSource
        return compileParseTreePattern(pattern, patternRuleIndex, lexer)
      end
    end
    raise UnsupportedOperationException, "Parser can't discover a lexer to use"
  end


  def compileParseTreePattern_2(pattern, patternRuleIndex, lexer)

    m = ParseTreePatternMatcher.new(lexer, self)
    return m.compile(pattern, patternRuleIndex)
  end


  def getErrorHandler()
    return @_errHandler
  end

  def setErrorHandler(handler)
    @_errHandler = handler
  end


  def getInputStream()
    return getTokenStream()
  end


  def setInputStream(input)
    setTokenStream(input)
  end

  def getTokenStream()
    return @_input
  end


  def setTokenStream(input)
    @_input = nil
    reset()
    @_input = input
  end


  def getCurrentToken()
    return @_input.LT(1)
  end

  def notifyErrorListeners_simple(msg)
    notifyErrorListeners(getCurrentToken(), msg, nil)
  end

  def notifyErrorListeners(offendingToken, msg, e)

    _syntaxErrors += 1
    line = -1
    charPositionInLine = -1
    line = offendingToken.getLine()
    charPositionInLine = offendingToken.getCharPositionInLine()

    listener = getErrorListenerDispatch()
    listener.syntaxError(self, offendingToken, line, charPositionInLine, msg, e)
  end


  def consume()
    o = getCurrentToken()
    if (o.getType() != EOF)
      getInputStream().consume()
    end
    hasListener = @_parseListeners != nil && !@_parseListeners.isEmpty()
    if (@_buildParseTrees || hasListener)
      if (@_errHandler.inErrorRecoveryMode(self))
        node = @_ctx.addErrorNode(createErrorNode(@_ctx, o))
        if (@_parseListeners != nil)
          @_parseListeners.each do |listener|
            listener.visitErrorNode(node)
          end
        end
      else
        node = @_ctx.addChild(createTerminalNode(@_ctx, o))
        if (@_parseListeners != nil)
          @_parseListeners.each do |listener|
            listener.visitTerminal(node)
          end
        end
      end
    end

    return o
  end


  def createTerminalNode(parent, t)
    return TerminalNodeImpl.new(t)
  end


  def createErrorNode(parent, t)
    return ErrorNodeImpl.new(t)
  end

  def addContextToParseTree()
    parent = @_ctx.parent
# add current context to parent if we have a parent
    if (parent != nil)
      parent.addChild(@_ctx)
    end
  end


  def enterRule(localctx, state, ruleIndex)
    setState(state)
    @_ctx = localctx
    @_ctx.start = @_input.LT(1)
    if (@_buildParseTrees)
      addContextToParseTree()
    end
    if (@_parseListeners != nil)
      triggerEnterRuleEvent()
    end
  end

  def exitRule()
    if (@matchedEOF)
      # if we have matched EOF, it cannot consume past EOF so we use LT(1) here
      @_ctx.stop = @_input.LT(1) # LT(1) will be end of file
    else
      @_ctx.stop = @_input.LT(-1) # stop node is what we just matched
    end

# trigger event on @_ctx, before it reverts to parent
    if (@_parseListeners != nil)
      triggerExitRuleEvent()
    end
    setState(@_ctx.invokingState)
    @_ctx = @_ctx.parent
  end

  def enterOuterAlt(localctx, altNum)
    localctx.setAltNumber(altNum)
# if we have new localctx, make sure we replace existing ctx
# that is previous child of parse tree
    if (@_buildParseTrees && @_ctx != localctx)
      parent = @_ctx.parent
      if (parent != nil)
        parent.removeLastChild()
        parent.addChild(localctx)
      end
    end
    @_ctx = localctx
  end


  def getPrecedence()
    if (@_precedenceStack.isEmpty())
      return -1
    end

    return @_precedenceStack.peek()
  end


  def enterRecursionRule(localctx, state, ruleIndex, precedence)
    setState(state)
    @_precedenceStack.push(precedence)
    @_ctx = localctx
    @_ctx.start = @_input.LT(1)
    if (@_parseListeners != nil)
      triggerEnterRuleEvent() # simulates rule entry for left-recursive rules
    end
  end


  def pushNewRecursionContext(localctx, state, ruleIndex)
    previous = @_ctx
    previous.parent = localctx
    previous.invokingState = state
    previous.stop = @_input.LT(-1)

    @_ctx = localctx
    @_ctx.start = previous.start
    if (@_buildParseTrees)
      @_ctx.addChild(previous)
    end

    if (@_parseListeners != nil)
      triggerEnterRuleEvent() # simulates rule entry for left-recursive rules
    end
  end

  def unrollRecursionContexts(_parentctx)
    @_precedenceStack.pop()
    @_ctx.stop = @_input.LT(-1)
    retctx = @_ctx # save current ctx (return value)

# unroll so @_ctx is as it was before call to recursive method
    if (@_parseListeners != nil)
      while (@_ctx != _parentctx)
        triggerExitRuleEvent()
        @_ctx = @_ctx.parent
      end

    else
      _ctx = _parentctx
    end

# hook into tree
    retctx.parent = _parentctx

    if (@_buildParseTrees && _parentctx != nil)
      # add return ctx into invoking rule's tree
      _parentctx.addChild(retctx)
    end
  end

  def getInvokingContext(ruleIndex)
    p = @_ctx
    while (p != nil)
      if (p.getRuleIndex() == ruleIndex)
        return p
      end
      p = p.parent
    end
    return nil
  end

  def getContext()
    return @_ctx
  end

  def setContext(ctx)
    @_ctx = ctx
  end


  def precpred(localctx, precedence)
    return precedence >= @_precedenceStack.peek()
  end

  def inContext(context)
    return false
  end


  def isExpectedToken(symbol)
    atn = getInterpreter().atn
    ctx = @_ctx
    s = atn.states.get(getState())
    following = atn.nextTokens(s)
    if (following.include?(symbol))
      return true
    end

    if (!following.contains(Token.EPSILON))
      return false
    end

    while (ctx != nil && ctx.invokingState >= 0 && following.include?(Token.EPSILON))
      invokingState = atn.states.get(ctx.invokingState)
      rt = invokingState.transition(0)
      following = atn.nextTokens(rt.followState)
      if (following.include?(symbol))
        return true
      end

      ctx = ctx.parent
    end

    if (following.include?(Token.EPSILON) && symbol == Token.EOF)
      return true
    end

    return false
  end

  def isMatchedEOF()
    return @matchedEOF
  end


  def getExpectedTokens()
    return getATN().getExpectedTokens(getState(), getContext())
  end


  def getExpectedTokensWithinCurrentRule()
    atn = getInterpreter().atn
    s = atn.states.get(getState())
    return atn.nextTokens(s)
  end


  def getRuleIndex(ruleName)
    ruleIndex = getRuleIndexMap().get(ruleName)
    if (ruleIndex != nil)
      return ruleIndex
    end
    return -1
  end

  def getRuleContext()
    return @_ctx
  end


  def getRuleInvocationStack_1()
    return getRuleInvocationStack(@_ctx)
  end

  def getRuleInvocationStack_2(p)
    ruleNames = getRuleNames()
    stack = []
    while (p != nil)
      # compute what follows who invoked us
      ruleIndex = p.getRuleIndex()
      if (ruleIndex < 0)
        stack.push("n/a")
      else
        stack.push(ruleNames[ruleIndex])
      end
      p = p.parent
    end
    return stack
  end


  def getDFAStrings()
    s = []
    d = 0
    while d < @_interp.decisionToDFA.length
      dfa = @_interp.decisionToDFA[d]
      s.push(dfa.to_s(getVocabulary()))
      d += 1
    end
    return s
  end


  def dumpDFA()
    boolean seenOne = false
    d = 0
    while d < @_interp.decisionToDFA.length
      dfa = @_interp.decisionToDFA[d]
      if (!dfa.states.isEmpty())
        if (seenOne)
          System.out.println()
        end
        System.out.println("Decision " + dfa.decision + ":")
        System.out.print(dfa.to_s(getVocabulary()))
        seenOne = true
      end
      d += 1
    end
  end

  def getSourceName()
    return @_input.getSourceName()
  end


  def getParseInfo()
    interp = getInterpreter()
    if (interp.is_a? ProfilingATNSimulator)
      return ParseInfo.new(interp)
    end
    return nil
  end


  def setProfile(profile)
    interp = getInterpreter()
    saveMode = interp.getPredictionMode()
    if (profile)
      if (!(interp.is_a? ProfilingATNSimulator))
        setInterpreter(ProfilingATNSimulator.new(self))
      end
    elsif (interp instanceof ProfilingATNSimulator)
      sim = ParserATNSimulator.new(self, getATN(), interp.decisionToDFA, interp.getSharedContextCache())
      setInterpreter(sim)
    end
    getInterpreter().setPredictionMode(saveMode)
  end


  def setTrace(trace)
    if (!trace)
      removeParseListener(@_tracer)
      @_tracer = nil
    else
      if (@_tracer != nil)
        removeParseListener(@_tracer)
      else
        @_tracer = new TraceListener()
      end
      addParseListener(@_tracer)
    end
  end


  def isTrace()
    return @_tracer != nil
  end
end

