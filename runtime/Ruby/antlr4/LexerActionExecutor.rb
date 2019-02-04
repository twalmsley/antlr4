


























class LexerActionExecutor 

	private final LexerAction[] lexerActions




	private final int hashCode





	public LexerActionExecutor(LexerAction[] lexerActions) 
		this.lexerActions = lexerActions

		int hash = MurmurHash.initialize()
		for (LexerAction lexerAction : lexerActions) 
			hash = MurmurHash.update(hash, lexerAction)
		end

		this.hashCode = MurmurHash.finish(hash, lexerActions.length)
	end
















	public static LexerActionExecutor append(LexerActionExecutor lexerActionExecutor, LexerAction lexerAction) 
		if (lexerActionExecutor == null) 
			return new LexerActionExecutor(new LexerAction[]  lexerAction end)
		end

		LexerAction[] lexerActions = Arrays.copyOf(lexerActionExecutor.lexerActions, lexerActionExecutor.lexerActions.length + 1)
		lexerActions[lexerActions.length - 1] = lexerAction
		return new LexerActionExecutor(lexerActions)
	end






























	public LexerActionExecutor fixOffsetBeforeMatch(int offset) 
		LexerAction[] updatedLexerActions = null
		for (int i = 0 i < lexerActions.length i++) 
			if (lexerActions[i].isPositionDependent() && !(lexerActions[i] instanceof LexerIndexedCustomAction)) 
				if (updatedLexerActions == null) 
					updatedLexerActions = lexerActions.clone()
				end

				updatedLexerActions[i] = new LexerIndexedCustomAction(offset, lexerActions[i])
			end
		end

		if (updatedLexerActions == null) 
			return this
		end

		return new LexerActionExecutor(updatedLexerActions)
	end





	public LexerAction[] getLexerActions() 
		return lexerActions
	end




















	public void execute(Lexer lexer, CharStream input, int startIndex) 
		boolean requiresSeek = false
		int stopIndex = input.index()
		try 
			for (LexerAction lexerAction : lexerActions) 
				if (lexerAction instanceof LexerIndexedCustomAction) 
					int offset = ((LexerIndexedCustomAction)lexerAction).getOffset()
					input.seek(startIndex + offset)
					lexerAction = ((LexerIndexedCustomAction)lexerAction).getAction()
					requiresSeek = (startIndex + offset) != stopIndex
				end
				else if (lexerAction.isPositionDependent()) 
					input.seek(stopIndex)
					requiresSeek = false
				end

				lexerAction.execute(lexer)
			end
		end
		finally 
			if (requiresSeek) 
				input.seek(stopIndex)
			end
		end
	end

	
	public int hashCode() 
		return this.hashCode
	end

	
	public boolean equals(Object obj) 
		if (obj == this) 
			return true
		end
		else if (!(obj instanceof LexerActionExecutor)) 
			return false
		end

		LexerActionExecutor other = (LexerActionExecutor)obj
		return hashCode == other.hashCode
			&& Arrays.equals(lexerActions, other.lexerActions)
	end
end
