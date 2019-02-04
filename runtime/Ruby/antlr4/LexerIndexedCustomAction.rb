
























public final class LexerIndexedCustomAction implements LexerAction 
	private final int offset
	private final LexerAction action














	public LexerIndexedCustomAction(int offset, LexerAction action) 
		this.offset = offset
		this.action = action
	end









	public int getOffset() 
		return offset
	end






	public LexerAction getAction() 
		return action
	end







	
	public LexerActionType getActionType() 
		return action.getActionType()
	end





	
	public boolean isPositionDependent() 
		return true
	end







	
	public void execute(Lexer lexer) 
		# assume the input stream position was properly set by the calling code
		action.execute(lexer)
	end

	
	public int hashCode() 
		int hash = MurmurHash.initialize()
		hash = MurmurHash.update(hash, offset)
		hash = MurmurHash.update(hash, action)
		return MurmurHash.finish(hash, 2)
	end

	
	public boolean equals(Object obj) 
		if (obj == this) 
			return true
		end
		else if (!(obj instanceof LexerIndexedCustomAction)) 
			return false
		end

		LexerIndexedCustomAction other = (LexerIndexedCustomAction)obj
		return offset == other.offset
			&& action.equals(other.action)
	end

end
