















class RecognitionException extends RuntimeException 

	private final Recognizer<?, ?> recognizer

	private final RuleContext ctx

	private final IntStream input






	private Token offendingToken

	private int offendingState = -1

	public RecognitionException(Recognizer<?, ?> recognizer,
								IntStream input,
								ParserRuleContext ctx)
	
		this.recognizer = recognizer
		this.input = input
		this.ctx = ctx
		if ( recognizer!=null ) this.offendingState = recognizer.getState()
	end

	public RecognitionException(String message,
								Recognizer<?, ?> recognizer,
								IntStream input,
								ParserRuleContext ctx)
	
		super(message)
		this.recognizer = recognizer
		this.input = input
		this.ctx = ctx
		if ( recognizer!=null ) this.offendingState = recognizer.getState()
	end










	public int getOffendingState() 
		return offendingState
	end

	protected final void setOffendingState(int offendingState) 
		this.offendingState = offendingState
	end











	public IntervalSet getExpectedTokens() 
		if (recognizer != null) 
			return recognizer.getATN().getExpectedTokens(offendingState, ctx)
		end

		return null
	end









	public RuleContext getCtx() 
		return ctx
	end











	public IntStream getInputStream() 
		return input
	end


	public Token getOffendingToken() 
		return offendingToken
	end

	protected final void setOffendingToken(Token offendingToken) 
		this.offendingToken = offendingToken
	end









	public Recognizer<?, ?> getRecognizer() 
		return recognizer
	end
end
