



















public final class LexerSkipAction implements LexerAction 



	public static final LexerSkipAction INSTANCE = new LexerSkipAction()




	private LexerSkipAction() 
	end





	
	public LexerActionType getActionType() 
		return LexerActionType.SKIP
	end





	
	public boolean isPositionDependent() 
		return false
	end






	
	public void execute(Lexer lexer) 
		lexer.skip()
	end

	
	public int hashCode() 
		int hash = MurmurHash.initialize()
		hash = MurmurHash.update(hash, getActionType().ordinal())
		return MurmurHash.finish(hash, 1)
	end

	
	@SuppressWarnings("EqualsWhichDoesntCheckParameterClass")
	public boolean equals(Object obj) 
		return obj == this
	end

	
	public String toString() 
		return "skip"
	end
end
