

















class LexerTypeAction implements LexerAction 
	private final int type





	public LexerTypeAction(int type) 
		this.type = type
	end





	public int getType() 
		return type
	end





	
	public LexerActionType getActionType() 
		return LexerActionType.TYPE
	end





	
	public boolean isPositionDependent() 
		return false
	end







	
	public void execute(Lexer lexer) 
		lexer.setType(type)
	end

	
	public int hashCode() 
		int hash = MurmurHash.initialize()
		hash = MurmurHash.update(hash, getActionType().ordinal())
		hash = MurmurHash.update(hash, type)
		return MurmurHash.finish(hash, 2)
	end

	
	public boolean equals(Object obj) 
		if (obj == this) 
			return true
		end
		else if (!(obj instanceof LexerTypeAction)) 
			return false
		end

		return type == ((LexerTypeAction)obj).type
	end

	
	public String toString() 
		return String.format("type(%d)", type)
	end
end
