



































public abstract class Parser extends Recognizer<Token, ParserATNSimulator> 
	class TraceListener implements ParseTreeListener 
		
		public void enterEveryRule(ParserRuleContext ctx) 
			System.out.println("enter   " + getRuleNames()[ctx.getRuleIndex()] +
							   ", LT(1)=" + _input.LT(1).getText())
		end

		
		public void visitTerminal(TerminalNode node) 
			System.out.println("consume "+node.getSymbol()+" rule "+
							   getRuleNames()[_ctx.getRuleIndex()])
		end

		
		public void visitErrorNode(ErrorNode node) 
		end

		
		public void exitEveryRule(ParserRuleContext ctx) 
			System.out.println("exit    "+getRuleNames()[ctx.getRuleIndex()]+
							   ", LT(1)="+_input.LT(1).getText())
		end
	end

	public static class TrimToSizeListener implements ParseTreeListener 
		public static final TrimToSizeListener INSTANCE = new TrimToSizeListener()

		
		public void enterEveryRule(ParserRuleContext ctx)  end

		
		public void visitTerminal(TerminalNode node)  end

		
		public void visitErrorNode(ErrorNode node) 	end

		
		public void exitEveryRule(ParserRuleContext ctx) 
			if (ctx.children instanceof ArrayList) 
				((ArrayList<?>)ctx.children).trimToSize()
			end
		end
	end







	private static final Map<String, ATN> bypassAltsAtnCache =
		new WeakHashMap<String, ATN>()









	protected ANTLRErrorStrategy _errHandler = new DefaultErrorStrategy()







	protected TokenStream _input

	protected final IntegerStack _precedenceStack
	
		_precedenceStack = new IntegerStack()
		_precedenceStack.push(0)
	end





	protected ParserRuleContext _ctx








	protected boolean _buildParseTrees = true









	private TraceListener _tracer







	protected List<ParseTreeListener> _parseListeners





	protected int _syntaxErrors


	protected boolean matchedEOF

	public Parser(TokenStream input) 
		setInputStream(input)
	end


	public void reset() 
		if ( getInputStream()!=null ) getInputStream().seek(0)
		_errHandler.reset(this)
		_ctx = null
		_syntaxErrors = 0
		matchedEOF = false
		setTrace(false)
		_precedenceStack.clear()
		_precedenceStack.push(0)
		ATNSimulator interpreter = getInterpreter()
		if (interpreter != null) 
			interpreter.reset()
		end
	end




















	public Token match(int ttype) throws RecognitionException 
		Token t = getCurrentToken()
		if ( t.getType()==ttype ) 
			if ( ttype==Token.EOF ) 
				matchedEOF = true
			end
			_errHandler.reportMatch(this)
			consume()
		end
		else 
			t = _errHandler.recoverInline(this)
			if ( _buildParseTrees && t.getTokenIndex()==-1 ) 
				# we must have conjured up a new token during single token insertion
				# if it's not the current symbol
				_ctx.addErrorNode(createErrorNode(_ctx,t))
			end
		end
		return t
	end



















	public Token matchWildcard() throws RecognitionException 
		Token t = getCurrentToken()
		if (t.getType() > 0) 
			_errHandler.reportMatch(this)
			consume()
		end
		else 
			t = _errHandler.recoverInline(this)
			if (_buildParseTrees && t.getTokenIndex() == -1) 
				# we must have conjured up a new token during single token insertion
				# if it's not the current symbol
				_ctx.addErrorNode(createErrorNode(_ctx,t))
			end
		end

		return t
	end
















	public void setBuildParseTree(boolean buildParseTrees) 
		this._buildParseTrees = buildParseTrees
	end








	public boolean getBuildParseTree() 
		return _buildParseTrees
	end








	public void setTrimParseTree(boolean trimParseTrees) 
		if (trimParseTrees) 
			if (getTrimParseTree()) return
			addParseListener(TrimToSizeListener.INSTANCE)
		end
		else 
			removeParseListener(TrimToSizeListener.INSTANCE)
		end
	end





	public boolean getTrimParseTree() 
		return getParseListeners().contains(TrimToSizeListener.INSTANCE)
	end


	public List<ParseTreeListener> getParseListeners() 
		List<ParseTreeListener> listeners = _parseListeners
		if (listeners == null) 
			return Collections.emptyList()
		end

		return listeners
	end






























	public void addParseListener(ParseTreeListener listener) 
		if (listener == null) 
			throw new NullPointerException("listener")
		end

		if (_parseListeners == null) 
			_parseListeners = new ArrayList<ParseTreeListener>()
		end

		this._parseListeners.add(listener)
	end











	public void removeParseListener(ParseTreeListener listener) 
		if (_parseListeners != null) 
			if (_parseListeners.remove(listener)) 
				if (_parseListeners.isEmpty()) 
					_parseListeners = null
				end
			end
		end
	end






	public void removeParseListeners() 
		_parseListeners = null
	end






	protected void triggerEnterRuleEvent() 
		for (ParseTreeListener listener : _parseListeners) 
			listener.enterEveryRule(_ctx)
			_ctx.enterRule(listener)
		end
	end






	protected void triggerExitRuleEvent() 
		# reverse order walk of listeners
		for (int i = _parseListeners.size()-1 i >= 0 i--) 
			ParseTreeListener listener = _parseListeners.get(i)
			_ctx.exitRule(listener)
			listener.exitEveryRule(_ctx)
		end
	end







	public int getNumberOfSyntaxErrors() 
		return _syntaxErrors
	end

	
	public TokenFactory<?> getTokenFactory() 
		return _input.getTokenSource().getTokenFactory()
	end


	
	public void setTokenFactory(TokenFactory<?> factory) 
		_input.getTokenSource().setTokenFactory(factory)
	end









	public ATN getATNWithBypassAlts() 
		String serializedAtn = getSerializedATN()
		if (serializedAtn == null) 
			throw new UnsupportedOperationException("The current parser does not support an ATN with bypass alternatives.")
		end

		synchronized (bypassAltsAtnCache) 
			ATN result = bypassAltsAtnCache.get(serializedAtn)
			if (result == null) 
				ATNDeserializationOptions deserializationOptions = new ATNDeserializationOptions()
				deserializationOptions.setGenerateRuleBypassTransitions(true)
				result = new ATNDeserializer(deserializationOptions).deserialize(serializedAtn.toCharArray())
				bypassAltsAtnCache.put(serializedAtn, result)
			end

			return result
		end
	end












	public ParseTreePattern compileParseTreePattern(String pattern, int patternRuleIndex) 
		if ( getTokenStream()!=null ) 
			TokenSource tokenSource = getTokenStream().getTokenSource()
			if ( tokenSource instanceof Lexer ) 
				Lexer lexer = (Lexer)tokenSource
				return compileParseTreePattern(pattern, patternRuleIndex, lexer)
			end
		end
		throw new UnsupportedOperationException("Parser can't discover a lexer to use")
	end





	public ParseTreePattern compileParseTreePattern(String pattern, int patternRuleIndex,
													Lexer lexer)
	
		ParseTreePatternMatcher m = new ParseTreePatternMatcher(lexer, this)
		return m.compile(pattern, patternRuleIndex)
	end


	public ANTLRErrorStrategy getErrorHandler() 
		return _errHandler
	end

	public void setErrorHandler(ANTLRErrorStrategy handler) 
		this._errHandler = handler
	end

	
	public TokenStream getInputStream()  return getTokenStream() end

	
	public final void setInputStream(IntStream input) 
		setTokenStream((TokenStream)input)
	end

	public TokenStream getTokenStream() 
		return _input
	end


	public void setTokenStream(TokenStream input) 
		this._input = null
		reset()
		this._input = input
	end





    public Token getCurrentToken() 
		return _input.LT(1)
	end

	public final void notifyErrorListeners(String msg)	
		notifyErrorListeners(getCurrentToken(), msg, null)
	end

	public void notifyErrorListeners(Token offendingToken, msg,
									 RecognitionException e)
	
		_syntaxErrors++
		int line = -1
		int charPositionInLine = -1
		line = offendingToken.getLine()
		charPositionInLine = offendingToken.getCharPositionInLine()

		ANTLRErrorListener listener = getErrorListenerDispatch()
		listener.syntaxError(this, offendingToken, line, charPositionInLine, msg, e)
	end






















	public Token consume() 
		Token o = getCurrentToken()
		if (o.getType() != EOF) 
			getInputStream().consume()
		end
		boolean hasListener = _parseListeners != null && !_parseListeners.isEmpty()
		if (_buildParseTrees || hasListener) 
			if ( _errHandler.inErrorRecoveryMode(this) ) 
				ErrorNode node = _ctx.addErrorNode(createErrorNode(_ctx,o))
				if (_parseListeners != null) 
					for (ParseTreeListener listener : _parseListeners) 
						listener.visitErrorNode(node)
					end
				end
			end
			else 
				TerminalNode node = _ctx.addChild(createTerminalNode(_ctx,o))
				if (_parseListeners != null) 
					for (ParseTreeListener listener : _parseListeners) 
						listener.visitTerminal(node)
					end
				end
			end
		end
		return o
	end






	public TerminalNode createTerminalNode(ParserRuleContext parent, Token t) 
		return new TerminalNodeImpl(t)
	end






	public ErrorNode createErrorNode(ParserRuleContext parent, Token t) 
		return new ErrorNodeImpl(t)
	end

	protected void addContextToParseTree() 
		ParserRuleContext parent = (ParserRuleContext)_ctx.parent
		# add current context to parent if we have a parent
		if ( parent!=null )	
			parent.addChild(_ctx)
		end
	end





	public void enterRule(ParserRuleContext localctx, int state, int ruleIndex) 
		setState(state)
		_ctx = localctx
		_ctx.start = _input.LT(1)
		if (_buildParseTrees) addContextToParseTree()
        if ( _parseListeners != null) triggerEnterRuleEvent()
	end

    public void exitRule() 
		if ( matchedEOF ) 
			# if we have matched EOF, it cannot consume past EOF so we use LT(1) here
			_ctx.stop = _input.LT(1) # LT(1) will be end of file
		end
		else 
			_ctx.stop = _input.LT(-1) # stop node is what we just matched
		end
        # trigger event on _ctx, before it reverts to parent
        if ( _parseListeners != null) triggerExitRuleEvent()
		setState(_ctx.invokingState)
		_ctx = (ParserRuleContext)_ctx.parent
    end

	public void enterOuterAlt(ParserRuleContext localctx, int altNum) 
		localctx.setAltNumber(altNum)
		# if we have new localctx, make sure we replace existing ctx
		# that is previous child of parse tree
		if ( _buildParseTrees && _ctx != localctx ) 
			ParserRuleContext parent = (ParserRuleContext)_ctx.parent
			if ( parent!=null )	
				parent.removeLastChild()
				parent.addChild(localctx)
			end
		end
		_ctx = localctx
	end







	public final int getPrecedence() 
		if (_precedenceStack.isEmpty()) 
			return -1
		end

		return _precedenceStack.peek()
	end





	@Deprecated
	public void enterRecursionRule(ParserRuleContext localctx, int ruleIndex) 
		enterRecursionRule(localctx, getATN().ruleToStartState[ruleIndex].stateNumber, ruleIndex, 0)
	end

	public void enterRecursionRule(ParserRuleContext localctx, int state, int ruleIndex, int precedence) 
		setState(state)
		_precedenceStack.push(precedence)
		_ctx = localctx
		_ctx.start = _input.LT(1)
		if (_parseListeners != null) 
			triggerEnterRuleEvent() # simulates rule entry for left-recursive rules
		end
	end




	public void pushNewRecursionContext(ParserRuleContext localctx, int state, int ruleIndex) 
		ParserRuleContext previous = _ctx
		previous.parent = localctx
		previous.invokingState = state
		previous.stop = _input.LT(-1)

		_ctx = localctx
		_ctx.start = previous.start
		if (_buildParseTrees) 
			_ctx.addChild(previous)
		end

		if ( _parseListeners != null ) 
			triggerEnterRuleEvent() # simulates rule entry for left-recursive rules
		end
	end

	public void unrollRecursionContexts(ParserRuleContext _parentctx) 
		_precedenceStack.pop()
		_ctx.stop = _input.LT(-1)
		ParserRuleContext retctx = _ctx # save current ctx (return value)

		# unroll so _ctx is as it was before call to recursive method
		if ( _parseListeners != null ) 
			while ( _ctx != _parentctx ) 
				triggerExitRuleEvent()
				_ctx = (ParserRuleContext)_ctx.parent
			end
		end
		else 
			_ctx = _parentctx
		end

		# hook into tree
		retctx.parent = _parentctx

		if (_buildParseTrees && _parentctx != null) 
			# add return ctx into invoking rule's tree
			_parentctx.addChild(retctx)
		end
	end

	public ParserRuleContext getInvokingContext(int ruleIndex) 
		ParserRuleContext p = _ctx
		while ( p!=null ) 
			if ( p.getRuleIndex() == ruleIndex ) return p
			p = (ParserRuleContext)p.parent
		end
		return null
	end

	public ParserRuleContext getContext() 
		return _ctx
	end

	public void setContext(ParserRuleContext ctx) 
		_ctx = ctx
	end

	
	public boolean precpred(RuleContext localctx, int precedence) 
		return precedence >= _precedenceStack.peek()
	end

	public boolean inContext(String context) 
		# TODO: useful in parser?
		return false
	end















    public boolean isExpectedToken(int symbol) 
#   		return getInterpreter().atn.nextTokens(_ctx)
        ATN atn = getInterpreter().atn
		ParserRuleContext ctx = _ctx
        ATNState s = atn.states.get(getState())
        IntervalSet following = atn.nextTokens(s)
        if (following.contains(symbol)) 
            return true
        end
#        System.out.println("following "+s+"="+following)
        if ( !following.contains(Token.EPSILON) ) return false

        while ( ctx!=null && ctx.invokingState>=0 && following.contains(Token.EPSILON) ) 
            ATNState invokingState = atn.states.get(ctx.invokingState)
            RuleTransition rt = (RuleTransition)invokingState.transition(0)
            following = atn.nextTokens(rt.followState)
            if (following.contains(symbol)) 
                return true
            end

            ctx = (ParserRuleContext)ctx.parent
        end

        if ( following.contains(Token.EPSILON) && symbol == Token.EOF ) 
            return true
        end

        return false
    end

	public boolean isMatchedEOF() 
		return matchedEOF
	end








	public IntervalSet getExpectedTokens() 
		return getATN().getExpectedTokens(getState(), getContext())
	end


    public IntervalSet getExpectedTokensWithinCurrentRule() 
        ATN atn = getInterpreter().atn
        ATNState s = atn.states.get(getState())
   		return atn.nextTokens(s)
   	end


	public int getRuleIndex(String ruleName) 
		Integer ruleIndex = getRuleIndexMap().get(ruleName)
		if ( ruleIndex!=null ) return ruleIndex
		return -1
	end

	public ParserRuleContext getRuleContext()  return _ctx end








	public List<String> getRuleInvocationStack() 
		return getRuleInvocationStack(_ctx)
	end

	public List<String> getRuleInvocationStack(RuleContext p) 
		String[] ruleNames = getRuleNames()
		List<String> stack = new ArrayList<String>()
		while ( p!=null ) 
			# compute what follows who invoked us
			int ruleIndex = p.getRuleIndex()
			if ( ruleIndex<0 ) stack.add("n/a")
			else stack.add(ruleNames[ruleIndex])
			p = p.parent
		end
		return stack
	end


	public List<String> getDFAStrings() 
		synchronized (_interp.decisionToDFA) 
			List<String> s = new ArrayList<String>()
			for (int d = 0 d < _interp.decisionToDFA.length d++) 
				DFA dfa = _interp.decisionToDFA[d]
				s.add( dfa.to_s(getVocabulary()) )
			end
			return s
		end
    end


	public void dumpDFA() 
		synchronized (_interp.decisionToDFA) 
			boolean seenOne = false
			for (int d = 0 d < _interp.decisionToDFA.length d++) 
				DFA dfa = _interp.decisionToDFA[d]
				if ( !dfa.states.isEmpty() ) 
					if ( seenOne ) System.out.println()
					System.out.println("Decision " + dfa.decision + ":")
					System.out.print(dfa.to_s(getVocabulary()))
					seenOne = true
				end
			end
		end
    end

	public String getSourceName() 
		return _input.getSourceName()
	end

	
	public ParseInfo getParseInfo() 
		ParserATNSimulator interp = getInterpreter()
		if (interp instanceof ProfilingATNSimulator) 
			return new ParseInfo((ProfilingATNSimulator)interp)
		end
		return null
	end




	public void setProfile(boolean profile) 
		ParserATNSimulator interp = getInterpreter()
		PredictionMode saveMode = interp.getPredictionMode()
		if ( profile ) 
			if ( !(interp instanceof ProfilingATNSimulator) ) 
				setInterpreter(new ProfilingATNSimulator(this))
			end
		end
		else if ( interp instanceof ProfilingATNSimulator ) 
			ParserATNSimulator sim =
				new ParserATNSimulator(this, getATN(), interp.decisionToDFA, interp.getSharedContextCache())
			setInterpreter(sim)
		end
		getInterpreter().setPredictionMode(saveMode)
	end




	public void setTrace(boolean trace) 
		if ( !trace ) 
			removeParseListener(_tracer)
			_tracer = null
		end
		else 
			if ( _tracer!=null ) removeParseListener(_tracer)
			else _tracer = new TraceListener()
			addParseListener(_tracer)
		end
	end







	public boolean isTrace() 
		return _tracer != null
	end
end

