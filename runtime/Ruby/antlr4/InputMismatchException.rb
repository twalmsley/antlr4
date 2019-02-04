









class InputMismatchException extends RecognitionException 
	public InputMismatchException(Parser recognizer) 
		super(recognizer, recognizer.getInputStream(), recognizer._ctx)
		this.setOffendingToken(recognizer.getCurrentToken())
	end

	public InputMismatchException(Parser recognizer, int state, ParserRuleContext ctx) 
		super(recognizer, recognizer.getInputStream(), ctx)
		this.setOffendingState(state)
		this.setOffendingToken(recognizer.getCurrentToken())
	end
end
