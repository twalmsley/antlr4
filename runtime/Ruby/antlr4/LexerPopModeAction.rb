



















public final class LexerPopModeAction implements LexerAction 



	public static final LexerPopModeAction INSTANCE = new LexerPopModeAction()




	private LexerPopModeAction() 
	end





	
	public LexerActionType getActionType() 
		return LexerActionType.POP_MODE
	end





	
	public boolean isPositionDependent() 
		return false
	end






	
	public void execute(Lexer lexer) 
		lexer.popMode()
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
		return "popMode"
	end
end
