

























public final class LexerCustomAction implements LexerAction 
	private final int ruleIndex
	private final int actionIndex










	public LexerCustomAction(int ruleIndex, int actionIndex) 
		this.ruleIndex = ruleIndex
		this.actionIndex = actionIndex
	end






	public int getRuleIndex() 
		return ruleIndex
	end






	public int getActionIndex() 
		return actionIndex
	end






	
	public LexerActionType getActionType() 
		return LexerActionType.CUSTOM
	end












	
	public boolean isPositionDependent() 
		return true
	end







	
	public void execute(Lexer lexer) 
		lexer.action(null, ruleIndex, actionIndex)
	end

	
	public int hashCode() 
		int hash = MurmurHash.initialize()
		hash = MurmurHash.update(hash, getActionType().ordinal())
		hash = MurmurHash.update(hash, ruleIndex)
		hash = MurmurHash.update(hash, actionIndex)
		return MurmurHash.finish(hash, 3)
	end

	
	public boolean equals(Object obj) 
		if (obj == this) 
			return true
		end
		else if (!(obj instanceof LexerCustomAction)) 
			return false
		end

		LexerCustomAction other = (LexerCustomAction)obj
		return ruleIndex == other.ruleIndex
			&& actionIndex == other.actionIndex
	end
end
