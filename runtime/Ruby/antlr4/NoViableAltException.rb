













class NoViableAltException extends RecognitionException 


	private final ATNConfigSet deadEndConfigs







	private final Token startToken

	public NoViableAltException(Parser recognizer)  # LL(1) error
		this(recognizer,
			 recognizer.getInputStream(),
			 recognizer.getCurrentToken(),
			 recognizer.getCurrentToken(),
			 null,
			 recognizer._ctx)
	end

	public NoViableAltException(Parser recognizer,
								TokenStream input,
								Token startToken,
								Token offendingToken,
								ATNConfigSet deadEndConfigs,
								ParserRuleContext ctx)
	
		super(recognizer, input, ctx)
		this.deadEndConfigs = deadEndConfigs
		this.startToken = startToken
		this.setOffendingToken(offendingToken)
	end


	public Token getStartToken() 
		return startToken
	end


	public ATNConfigSet getDeadEndConfigs() 
		return deadEndConfigs
	end

end
