



















public final class LexerMoreAction implements LexerAction 



	public static final LexerMoreAction INSTANCE = new LexerMoreAction()




	private LexerMoreAction() 
	end





	
	public LexerActionType getActionType() 
		return LexerActionType.MORE
	end





	
	public boolean isPositionDependent() 
		return false
	end






	
	public void execute(Lexer lexer) 
		lexer.more()
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
		return "more"
	end
end
