
















class RuleTagToken implements Token 



	private final String ruleName




	private final int bypassTokenType



	private final String label











	public RuleTagToken(String ruleName, int bypassTokenType) 
		this(ruleName, bypassTokenType, null)
	end













	public RuleTagToken(String ruleName, int bypassTokenType, label) 
		if (ruleName == null || ruleName.isEmpty()) 
			throw new IllegalArgumentException("ruleName cannot be null or empty.")
		end

		this.ruleName = ruleName
		this.bypassTokenType = bypassTokenType
		this.label = label
	end







	public final String getRuleName() 
		return ruleName
	end








	public final String getLabel() 
		return label
	end






	
	public int getChannel() 
		return DEFAULT_CHANNEL
	end







	
	public String getText() 
		if (label != null) 
			return "<" + label + ":" + ruleName + ">"
		end

		return "<" + ruleName + ">"
	end







	
	public int getType() 
		return bypassTokenType
	end






	
	public int getLine() 
		return 0
	end






	
	public int getCharPositionInLine() 
		return -1
	end






	
	public int getTokenIndex() 
		return -1
	end






	
	public int getStartIndex() 
		return -1
	end






	
	public int getStopIndex() 
		return -1
	end






	
	public TokenSource getTokenSource() 
		return null
	end






	
	public CharStream getInputStream() 
		return null
	end







	
	public String toString() 
		return ruleName + ":" + bypassTokenType
	end
end
