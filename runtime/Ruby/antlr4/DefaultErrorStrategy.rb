require '../../antlr4/runtime/Ruby/antlr4/ANTLRErrorStrategy'
require '../../antlr4/runtime/Ruby/antlr4/NoViableAltException'
require '../../antlr4/runtime/Ruby/antlr4/InputMismatchException'

class DefaultErrorStrategy < ANTLRErrorStrategy


  @errorRecoveryMode = false


  @lastErrorIndex = -1

  @lastErrorStates = nil


  @nextTokensContext = nil


  @nextTokensState = nil


  def reset(recognizer)
    endErrorCondition(recognizer)
  end


  def beginErrorCondition(recognizer)
    @errorRecoveryMode = true
  end


  def inErrorRecoveryMode(recognizer)
    return @errorRecoveryMode
  end


  def endErrorCondition(recognizer)
    @errorRecoveryMode = false
    @lastErrorStates = nil
    @lastErrorIndex = -1
  end


  def reportMatch(recognizer)
    endErrorCondition(recognizer)
  end


  def reportError(recognizer, e)

# if we've already reported an error and have not matched a token
# yet successfully, don't report any errors.
    if (inErrorRecoveryMode(recognizer))
#			System.err.print("[SPURIOUS] ")
      return # don't report spurious errors
    end
    beginErrorCondition(recognizer)
    if (e.is_a? NoViableAltException)
      reportNoViableAlternative(recognizer, e)
    elsif (e.is_a? InputMismatchException)
      reportInputMismatch(recognizer, e)
    elsif (e.is_a? FailedPredicateException)
      reportFailedPredicate(recognizer, e)
    else
      STDERR.println "unknown recognition error type: " + e.getClass().getName()
      recognizer.notifyErrorListeners(e.getOffendingToken(), e.getMessage(), e)
    end
  end


  def recover(recognizer, e)
    if (@lastErrorIndex == recognizer.getInputStream().index() &&
        @lastErrorStates != nil &&
        @lastErrorStates.include?(recognizer.getState()))
      # uh oh, another error at same token index and previously-visited
      # state in ATN must be a case where LT(1) is in the recovery
      # token set so nothing got consumed. Consume a single token
      # at least to prevent an infinite loop this is a failsafe.
      #			System.err.println("seen error condition before index="+
      #							   lastErrorIndex+", states="+lastErrorStates)
      #			System.err.println("FAILSAFE consumes "+recognizer.getTokenNames()[recognizer.getInputStream().LA(1)])
      recognizer.consume()
    end
    @lastErrorIndex = recognizer.getInputStream().index()
    if (@lastErrorStates == nil)
      lastErrorStates = IntervalSet.new
    end
    lastErrorStates.add(recognizer.getState())
    followSet = getErrorRecoverySet(recognizer)
    consumeUntil(recognizer, followSet)
  end


  def sync(recognizer)
    s = recognizer.getInterpreter().atn.states[recognizer.getState()]
#		System.err.println("sync @ "+s.stateNumber+"="+s.getClass().getSimpleName())
# If already recovering, don't try to sync
    if (inErrorRecoveryMode(recognizer))
      return
    end

    tokens = recognizer.getInputStream()
    la = tokens.LA(1)

# try cheaper subset first might get lucky. seems to shave a wee bit off
    nextTokens = recognizer.getATN().nextTokens(s)
    if (nextTokens.contains(la))
      # We are sure the token matches
      @nextTokensContext = nil
      @nextTokensState = ATNState::INVALID_STATE_NUMBER
      return
    end

    if (nextTokens.contains(Token::EPSILON))
      if (@nextTokensContext == nil)
        # It's possible the next token won't match information tracked
        # by sync is restricted for performance.
        @nextTokensContext = recognizer.getContext()
        @nextTokensState = recognizer.getState()
      end
      return
    end

    case (s.getStateType())
    when ATNState::BLOCK_START, ATNState::STAR_BLOCK_START, ATNState::PLUS_BLOCK_START, ATNState::STAR_LOOP_ENTRY
# report error and recover if possible
      if (singleTokenDeletion(recognizer) != nil)
        return
      end

      exc = InputMismatchException.create(recognizer)
      raise exc

    when ATNState::PLUS_LOOP_BACK, ATNState::STAR_LOOP_BACK

#			System.err.println("at loop back: "+s.getClass().getSimpleName())
      reportUnwantedToken(recognizer)
      expecting = recognizer.getExpectedTokens()
      whatFollowsLoopIterationOrRule =
          expecting.or(getErrorRecoverySet(recognizer))
      consumeUntil(recognizer, whatFollowsLoopIterationOrRule)

    else
# do nothing if we can't identify the exact kind of ATN state
    end
  end


  def reportNoViableAlternative(recognizer, e)

    tokens = recognizer.getInputStream()
    if (tokens != nil)
      if (e.getStartToken().getType() == Token::EOF)
        input = "<EOF>"
      else
        input = tokens.getText(e.getStartToken(), e.getOffendingToken())
      end
    else
      input = "<unknown input>"
    end
    msg = "no viable alternative at input " + escapeWSAndQuote(input)
    recognizer.notifyErrorListeners(e.getOffendingToken(), msg, e)
  end


  def reportInputMismatch(recognizer, e)
    msg = "mismatched input " + getTokenErrorDisplay(e.offendingToken) +
        " expecting " + e.getExpectedTokens().toString_from_Vocabulary(recognizer.getVocabulary())
    recognizer.notifyErrorListeners(e.offendingToken, msg, e)
  end


  def reportFailedPredicate(recognizer, e)
    ruleName = recognizer.getRuleNames()[recognizer._ctx.getRuleIndex()]
    msg = "rule " + ruleName + " " + e.getMessage()
    recognizer.notifyErrorListeners(e.getOffendingToken(), msg, e)
  end


  def reportUnwantedToken(recognizer)
    if (inErrorRecoveryMode(recognizer))
      return
    end

    beginErrorCondition(recognizer)

    t = recognizer.getCurrentToken()
    tokenName = getTokenErrorDisplay(t)
    expecting = getExpectedTokens(recognizer)
    msg = "extraneous input " + tokenName + " expecting " +
        expecting.to_s(recognizer.getVocabulary())
    recognizer.notifyErrorListeners(t, msg, nil)
  end


  def reportMissingToken(recognizer)
    if (inErrorRecoveryMode(recognizer))
      return
    end

    beginErrorCondition(recognizer)

    t = recognizer.getCurrentToken()
    expecting = getExpectedTokens(recognizer)
    msg = "missing " + expecting.to_s(recognizer.getVocabulary()) +
        " at " + getTokenErrorDisplay(t)

    recognizer.notifyErrorListeners(t, msg, nil)
  end


  def recoverInline(recognizer)

# SINGLE TOKEN DELETION
    matchedSymbol = singleTokenDeletion(recognizer)
    if (matchedSymbol != nil)
      # we have deleted the extra token.
      # now, move past ttype token as if all were ok
      recognizer.consume()
      return matchedSymbol
    end

# SINGLE TOKEN INSERTION
    if (singleTokenInsertion(recognizer))
      return getMissingSymbol(recognizer)
    end

# even that didn't work must throw the exception
    exc = InputMismatchException.new
    exc.recog = recognizer
    if (nextTokensContext == nil)
      raise exc
    else
      exc.token = @nextTokensState
      exc.context = @nextTokensContext
      raise exc
    end

  end


  def singleTokenInsertion(recognizer)
    currentSymbolType = recognizer.getInputStream().LA(1)
# if current token is consistent with what could come after current
# ATN state, then we know we're missing a token error recovery
# is free to conjure up and insert the missing token
    currentState = recognizer.getInterpreter().atn.states.get(recognizer.getState())
    nextt = currentState.transition(0).target
    atn = recognizer.getInterpreter().atn
    expectingAtLL2 = atn.nextTokens(nextt, recognizer._ctx)
#		System.out.println("LT(2) set="+expectingAtLL2.to_s(recognizer.getTokenNames()))
    if (expectingAtLL2.include?(currentSymbolType))
      reportMissingToken(recognizer)
      return true
    end
    false
  end


  def singleTokenDeletion(recognizer)
    nextTokenType = recognizer.getInputStream().LA(2)
    expecting = getExpectedTokens(recognizer)
    if (expecting.contains(nextTokenType))
      reportUnwantedToken(recognizer)

      recognizer.consume() # simply delete extra token
      # we want to return the token we're actually matching
      matchedSymbol = recognizer.getCurrentToken()
      reportMatch(recognizer) # we know current token is correct
      return matchedSymbol
    end
    nil
  end


  def getMissingSymbol(recognizer)
    currentSymbol = recognizer.getCurrentToken()
    expecting = getExpectedTokens(recognizer)
    expectedTokenType = Token::INVALID_TYPE
    if (!expecting.isNil())
      expectedTokenType = expecting.getMinElement() # get any element
    end
    tokenText = ""
    if (expectedTokenType == Token::EOF)
      tokenText = "<missing EOF>"
    else
      tokenText = "<missing " + recognizer.getVocabulary().getDisplayName(expectedTokenType) + ">"
    end
    current = currentSymbol
    lookback = recognizer.getInputStream().LT(-1)
    if (current.getType() == Token::EOF && lookback != nil)
      current = lookback
    end

    pair = OpenStruct.new
    pair.a = current.getTokenSource()
    pair.b = current.getTokenSource().getInputStream()
    return recognizer.getTokenFactory().create(pair, expectedTokenType, tokenText, Token::DEFAULT_CHANNEL, -1, -1, current.getLine(), current.getCharPositionInLine())
  end


  def getExpectedTokens(recognizer)
    return recognizer.getExpectedTokens()
  end


  def getTokenErrorDisplay(t)
    if (t == nil)
      return "<no token>"
    end
    s = getSymbolText(t)
    if (s == nil)
      if (getSymbolType(t) == Token::EOF)
        s = "<EOF>"
      else
        s = "<" + getSymbolType(t) + ">"
      end
    end

    return escapeWSAndQuote(s)
  end

  def getSymbolText(symbol)
    return symbol.getText()
  end

  def getSymbolType(symbol)
    return symbol.type
  end


  def escapeWSAndQuote(s)
#		if ( s==nil ) return s
    s = s.sub("\n", "\\n")
    s = s.sub("\r", "\\r")
    s = s.sub("\t", "\\t")
    return "'" + s + "'"
  end


  def getErrorRecoverySet(recognizer)
    atn = recognizer.getInterpreter().atn
    ctx = recognizer._ctx
    recoverSet = IntervalSet.new()
    while (ctx != nil && ctx.invokingState >= 0)
      # compute what follows who invoked us
      invokingState = atn.states.get(ctx.invokingState)
      rt = invokingState.transition(0)
      follow = atn.nextTokens(rt.followState)
      recoverSet.addAll(follow)
      ctx = ctx.parent
    end
    recoverSet.remove(Token::EPSILON)
    return recoverSet
  end


  def consumeUntil(recognizer, set)
#		System.err.println("consumeUntil("+set.to_s(recognizer.getTokenNames())+")")
    ttype = recognizer.getInputStream().LA(1)
    while (ttype != Token::EOF && !set.include?(ttype))
      recognizer.consume()
      ttype = recognizer.getInputStream().LA(1)
    end
  end
end
