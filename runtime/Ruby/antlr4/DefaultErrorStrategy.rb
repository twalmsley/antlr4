

















class DefaultErrorStrategy implements ANTLRErrorStrategy 







	protected boolean errorRecoveryMode = false







	protected int lastErrorIndex = -1

	protected IntervalSet lastErrorStates









	protected ParserRuleContext nextTokensContext




	protected int nextTokensState







	
	public void reset(Parser recognizer) 
		endErrorCondition(recognizer)
	end







	protected void beginErrorCondition(Parser recognizer) 
		errorRecoveryMode = true
	end




	
	public boolean inErrorRecoveryMode(Parser recognizer) 
		return errorRecoveryMode
	end







	protected void endErrorCondition(Parser recognizer) 
		errorRecoveryMode = false
		lastErrorStates = null
		lastErrorIndex = -1
	end






	
	public void reportMatch(Parser recognizer) 
		endErrorCondition(recognizer)
	end




















	
	public void reportError(Parser recognizer,
							RecognitionException e)
	
		# if we've already reported an error and have not matched a token
		# yet successfully, don't report any errors.
		if (inErrorRecoveryMode(recognizer)) 
#			System.err.print("[SPURIOUS] ")
			return # don't report spurious errors
		end
		beginErrorCondition(recognizer)
		if ( e instanceof NoViableAltException ) 
			reportNoViableAlternative(recognizer, (NoViableAltException) e)
		end
		else if ( e instanceof InputMismatchException ) 
			reportInputMismatch(recognizer, (InputMismatchException)e)
		end
		else if ( e instanceof FailedPredicateException ) 
			reportFailedPredicate(recognizer, (FailedPredicateException)e)
		end
		else 
			System.err.println("unknown recognition error type: "+e.getClass().getName())
			recognizer.notifyErrorListeners(e.getOffendingToken(), e.getMessage(), e)
		end
	end








	
	public void recover(Parser recognizer, RecognitionException e) 
#		System.out.println("recover in "+recognizer.getRuleInvocationStack()+
#						   " index="+recognizer.getInputStream().index()+
#						   ", lastErrorIndex="+
#						   lastErrorIndex+
#						   ", states="+lastErrorStates)
		if ( lastErrorIndex==recognizer.getInputStream().index() &&
			lastErrorStates != null &&
			lastErrorStates.contains(recognizer.getState()) ) 
			# uh oh, another error at same token index and previously-visited
			# state in ATN must be a case where LT(1) is in the recovery
			# token set so nothing got consumed. Consume a single token
			# at least to prevent an infinite loop this is a failsafe.
#			System.err.println("seen error condition before index="+
#							   lastErrorIndex+", states="+lastErrorStates)
#			System.err.println("FAILSAFE consumes "+recognizer.getTokenNames()[recognizer.getInputStream().LA(1)])
			recognizer.consume()
		end
		lastErrorIndex = recognizer.getInputStream().index()
		if ( lastErrorStates==null ) lastErrorStates = new IntervalSet()
		lastErrorStates.add(recognizer.getState())
		IntervalSet followSet = getErrorRecoverySet(recognizer)
		consumeUntil(recognizer, followSet)
	end















































	
	public void sync(Parser recognizer) throws RecognitionException 
		ATNState s = recognizer.getInterpreter().atn.states.get(recognizer.getState())
#		System.err.println("sync @ "+s.stateNumber+"="+s.getClass().getSimpleName())
		# If already recovering, don't try to sync
		if (inErrorRecoveryMode(recognizer)) 
			return
		end

        TokenStream tokens = recognizer.getInputStream()
        int la = tokens.LA(1)

        # try cheaper subset first might get lucky. seems to shave a wee bit off
		IntervalSet nextTokens = recognizer.getATN().nextTokens(s)
		if (nextTokens.contains(la)) 
			# We are sure the token matches
			nextTokensContext = null
			nextTokensState = ATNState.INVALID_STATE_NUMBER
			return
		end

		if (nextTokens.contains(Token.EPSILON)) 
			if (nextTokensContext == null) 
				# It's possible the next token won't match information tracked
				# by sync is restricted for performance.
				nextTokensContext = recognizer.getContext()
				nextTokensState = recognizer.getState()
			end
			return
		end

		switch (s.getStateType()) 
		case ATNState.BLOCK_START:
		case ATNState.STAR_BLOCK_START:
		case ATNState.PLUS_BLOCK_START:
		case ATNState.STAR_LOOP_ENTRY:
			# report error and recover if possible
			if ( singleTokenDeletion(recognizer)!=null ) 
				return
			end

			throw new InputMismatchException(recognizer)

		case ATNState.PLUS_LOOP_BACK:
		case ATNState.STAR_LOOP_BACK:
#			System.err.println("at loop back: "+s.getClass().getSimpleName())
			reportUnwantedToken(recognizer)
			IntervalSet expecting = recognizer.getExpectedTokens()
			IntervalSet whatFollowsLoopIterationOrRule =
				expecting.or(getErrorRecoverySet(recognizer))
			consumeUntil(recognizer, whatFollowsLoopIterationOrRule)
			break

		default:
			# do nothing if we can't identify the exact kind of ATN state
			break
		end
	end










	protected void reportNoViableAlternative(Parser recognizer,
											 NoViableAltException e)
	
		TokenStream tokens = recognizer.getInputStream()
		String input
		if ( tokens!=null ) 
			if ( e.getStartToken().getType()==Token.EOF ) input = "<EOF>"
			else input = tokens.getText(e.getStartToken(), e.getOffendingToken())
		end
		else 
			input = "<unknown input>"
		end
		String msg = "no viable alternative at input "+escapeWSAndQuote(input)
		recognizer.notifyErrorListeners(e.getOffendingToken(), msg, e)
	end










	protected void reportInputMismatch(Parser recognizer,
									   InputMismatchException e)
	
		String msg = "mismatched input "+getTokenErrorDisplay(e.getOffendingToken())+
		" expecting "+e.getExpectedTokens().to_s(recognizer.getVocabulary())
		recognizer.notifyErrorListeners(e.getOffendingToken(), msg, e)
	end










	protected void reportFailedPredicate(Parser recognizer,
										 FailedPredicateException e)
	
		String ruleName = recognizer.getRuleNames()[recognizer._ctx.getRuleIndex()]
		String msg = "rule "+ruleName+" "+e.getMessage()
		recognizer.notifyErrorListeners(e.getOffendingToken(), msg, e)
	end



















	protected void reportUnwantedToken(Parser recognizer) 
		if (inErrorRecoveryMode(recognizer)) 
			return
		end

		beginErrorCondition(recognizer)

		Token t = recognizer.getCurrentToken()
		String tokenName = getTokenErrorDisplay(t)
		IntervalSet expecting = getExpectedTokens(recognizer)
		String msg = "extraneous input "+tokenName+" expecting "+
			expecting.to_s(recognizer.getVocabulary())
		recognizer.notifyErrorListeners(t, msg, null)
	end


















	protected void reportMissingToken(Parser recognizer) 
		if (inErrorRecoveryMode(recognizer)) 
			return
		end

		beginErrorCondition(recognizer)

		Token t = recognizer.getCurrentToken()
		IntervalSet expecting = getExpectedTokens(recognizer)
		String msg = "missing "+expecting.to_s(recognizer.getVocabulary())+
			" at "+getTokenErrorDisplay(t)

		recognizer.notifyErrorListeners(t, msg, null)
	end



















































	
	public Token recoverInline(Parser recognizer)
		throws RecognitionException
	
		# SINGLE TOKEN DELETION
		Token matchedSymbol = singleTokenDeletion(recognizer)
		if ( matchedSymbol!=null ) 
			# we have deleted the extra token.
			# now, move past ttype token as if all were ok
			recognizer.consume()
			return matchedSymbol
		end

		# SINGLE TOKEN INSERTION
		if ( singleTokenInsertion(recognizer) ) 
			return getMissingSymbol(recognizer)
		end

		# even that didn't work must throw the exception
		InputMismatchException e
		if (nextTokensContext == null) 
			e = new InputMismatchException(recognizer)
		end else 
			e = new InputMismatchException(recognizer, nextTokensState, nextTokensContext)
		end

		throw e
	end


















	protected boolean singleTokenInsertion(Parser recognizer) 
		int currentSymbolType = recognizer.getInputStream().LA(1)
		# if current token is consistent with what could come after current
		# ATN state, then we know we're missing a token error recovery
		# is free to conjure up and insert the missing token
		ATNState currentState = recognizer.getInterpreter().atn.states.get(recognizer.getState())
		ATNState next = currentState.transition(0).target
		ATN atn = recognizer.getInterpreter().atn
		IntervalSet expectingAtLL2 = atn.nextTokens(next, recognizer._ctx)
#		System.out.println("LT(2) set="+expectingAtLL2.to_s(recognizer.getTokenNames()))
		if ( expectingAtLL2.contains(currentSymbolType) ) 
			reportMissingToken(recognizer)
			return true
		end
		return false
	end




















	protected Token singleTokenDeletion(Parser recognizer) 
		int nextTokenType = recognizer.getInputStream().LA(2)
		IntervalSet expecting = getExpectedTokens(recognizer)
		if ( expecting.contains(nextTokenType) ) 
			reportUnwantedToken(recognizer)

			System.err.println("recoverFromMismatchedToken deleting "+
							   ((TokenStream)recognizer.getInputStream()).LT(1)+
							   " since "+((TokenStream)recognizer.getInputStream()).LT(2)+
							   " is what we want")

			recognizer.consume() # simply delete extra token
			# we want to return the token we're actually matching
			Token matchedSymbol = recognizer.getCurrentToken()
			reportMatch(recognizer)  # we know current token is correct
			return matchedSymbol
		end
		return null
	end




















	protected Token getMissingSymbol(Parser recognizer) 
		Token currentSymbol = recognizer.getCurrentToken()
		IntervalSet expecting = getExpectedTokens(recognizer)
		int expectedTokenType = Token.INVALID_TYPE
		if ( !expecting.isNil() ) 
			expectedTokenType = expecting.getMinElement() # get any element
		end
		String tokenText
		if ( expectedTokenType== Token.EOF ) tokenText = "<missing EOF>"
		else tokenText = "<missing "+recognizer.getVocabulary().getDisplayName(expectedTokenType)+">"
		Token current = currentSymbol
		Token lookback = recognizer.getInputStream().LT(-1)
		if ( current.getType() == Token.EOF && lookback!=null ) 
			current = lookback
		end
		return
			recognizer.getTokenFactory().create(new Pair<TokenSource, CharStream>(current.getTokenSource(), current.getTokenSource().getInputStream()), expectedTokenType, tokenText,
							Token.DEFAULT_CHANNEL,
							-1, -1,
							current.getLine(), current.getCharPositionInLine())
	end


	protected IntervalSet getExpectedTokens(Parser recognizer) 
		return recognizer.getExpectedTokens()
	end









	protected String getTokenErrorDisplay(Token t) 
		if ( t==null ) return "<no token>"
		String s = getSymbolText(t)
		if ( s==null ) 
			if ( getSymbolType(t)==Token.EOF ) 
				s = "<EOF>"
			end
			else 
				s = "<"+getSymbolType(t)+">"
			end
		end
		return escapeWSAndQuote(s)
	end

	protected String getSymbolText(Token symbol) 
		return symbol.getText()
	end

	protected int getSymbolType(Token symbol) 
		return symbol.getType()
	end


	protected String escapeWSAndQuote(String s) 
#		if ( s==null ) return s
		s = s.replace("\n","\\n")
		s = s.replace("\r","\\r")
		s = s.replace("\t","\\t")
		return "'"+s+"'"
	end





























































































	protected IntervalSet getErrorRecoverySet(Parser recognizer) 
		ATN atn = recognizer.getInterpreter().atn
		RuleContext ctx = recognizer._ctx
		IntervalSet recoverSet = new IntervalSet()
		while ( ctx!=null && ctx.invokingState>=0 ) 
			# compute what follows who invoked us
			ATNState invokingState = atn.states.get(ctx.invokingState)
			RuleTransition rt = (RuleTransition)invokingState.transition(0)
			IntervalSet follow = atn.nextTokens(rt.followState)
			recoverSet.addAll(follow)
			ctx = ctx.parent
		end
        recoverSet.remove(Token.EPSILON)
#		System.out.println("recover set "+recoverSet.to_s(recognizer.getTokenNames()))
		return recoverSet
	end


	protected void consumeUntil(Parser recognizer, IntervalSet set) 
#		System.err.println("consumeUntil("+set.to_s(recognizer.getTokenNames())+")")
		int ttype = recognizer.getInputStream().LA(1)
		while (ttype != Token.EOF && !set.contains(ttype) ) 
            #System.out.println("consume during recover LA(1)="+getTokenNames()[input.LA(1)])
#			recognizer.getInputStream().consume()
            recognizer.consume()
            ttype = recognizer.getInputStream().LA(1)
        end
    end
end
