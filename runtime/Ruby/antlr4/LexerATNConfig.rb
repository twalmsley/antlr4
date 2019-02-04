










class LexerATNConfig extends ATNConfig 



	private final LexerActionExecutor lexerActionExecutor

	private final boolean passedThroughNonGreedyDecision

	public LexerATNConfig(ATNState state,
						  int alt,
						  PredictionContext context)
	
		super(state, alt, context, SemanticContext.NONE)
		this.passedThroughNonGreedyDecision = false
		this.lexerActionExecutor = null
	end

	public LexerATNConfig(ATNState state,
						  int alt,
						  PredictionContext context,
						  LexerActionExecutor lexerActionExecutor)
	
		super(state, alt, context, SemanticContext.NONE)
		this.lexerActionExecutor = lexerActionExecutor
		this.passedThroughNonGreedyDecision = false
	end

	public LexerATNConfig(LexerATNConfig c, ATNState state) 
		super(c, state, c.context, c.semanticContext)
		this.lexerActionExecutor = c.lexerActionExecutor
		this.passedThroughNonGreedyDecision = checkNonGreedyDecision(c, state)
	end

	public LexerATNConfig(LexerATNConfig c, ATNState state,
						  LexerActionExecutor lexerActionExecutor)
	
		super(c, state, c.context, c.semanticContext)
		this.lexerActionExecutor = lexerActionExecutor
		this.passedThroughNonGreedyDecision = checkNonGreedyDecision(c, state)
	end

	public LexerATNConfig(LexerATNConfig c, ATNState state,
						  PredictionContext context) 
		super(c, state, context, c.semanticContext)
		this.lexerActionExecutor = c.lexerActionExecutor
		this.passedThroughNonGreedyDecision = checkNonGreedyDecision(c, state)
	end





	public final LexerActionExecutor getLexerActionExecutor() 
		return lexerActionExecutor
	end

	public final boolean hasPassedThroughNonGreedyDecision() 
		return passedThroughNonGreedyDecision
	end

	
	public int hashCode() 
		int hashCode = MurmurHash.initialize(7)
		hashCode = MurmurHash.update(hashCode, state.stateNumber)
		hashCode = MurmurHash.update(hashCode, alt)
		hashCode = MurmurHash.update(hashCode, context)
		hashCode = MurmurHash.update(hashCode, semanticContext)
		hashCode = MurmurHash.update(hashCode, passedThroughNonGreedyDecision ? 1 : 0)
		hashCode = MurmurHash.update(hashCode, lexerActionExecutor)
		hashCode = MurmurHash.finish(hashCode, 6)
		return hashCode
	end

	
	public boolean equals(ATNConfig other) 
		if (this == other) 
			return true
		end
		else if (!(other instanceof LexerATNConfig)) 
			return false
		end

		LexerATNConfig lexerOther = (LexerATNConfig)other
		if (passedThroughNonGreedyDecision != lexerOther.passedThroughNonGreedyDecision) 
			return false
		end

		if (!ObjectEqualityComparator.INSTANCE.equals(lexerActionExecutor, lexerOther.lexerActionExecutor)) 
			return false
		end

		return super.equals(other)
	end

	private static boolean checkNonGreedyDecision(LexerATNConfig source, ATNState target) 
		return source.passedThroughNonGreedyDecision
			|| target instanceof DecisionState && ((DecisionState)target).nonGreedy
	end
end
