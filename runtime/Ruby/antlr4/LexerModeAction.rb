

















public final class LexerModeAction implements LexerAction 
	private final int mode





	public LexerModeAction(int mode) 
		this.mode = mode
	end






	public int getMode() 
		return mode
	end





	
	public LexerActionType getActionType() 
		return LexerActionType.MODE
	end





	
	public boolean isPositionDependent() 
		return false
	end







	
	public void execute(Lexer lexer) 
		lexer.mode(mode)
	end

	
	public int hashCode() 
		int hash = MurmurHash.initialize()
		hash = MurmurHash.update(hash, getActionType().ordinal())
		hash = MurmurHash.update(hash, mode)
		return MurmurHash.finish(hash, 2)
	end

	
	public boolean equals(Object obj) 
		if (obj == this) 
			return true
		end
		else if (!(obj instanceof LexerModeAction)) 
			return false
		end

		return mode == ((LexerModeAction)obj).mode
	end

	
	public String toString() 
		return String.format("mode(%d)", mode)
	end
end
