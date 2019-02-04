















class TokenTagToken extends CommonToken 




	private final String tokenName




	private final String label








	public TokenTagToken(String tokenName, int type) 
		this(tokenName, type, null)
	end










	public TokenTagToken(String tokenName, int type, label) 
		super(type)
		this.tokenName = tokenName
		this.label = label
	end






	public final String getTokenName() 
		return tokenName
	end








	public final String getLabel() 
		return label
	end







	
	public String getText() 
		if (label != null) 
			return "<" + label + ":" + tokenName + ">"
		end

		return "<" + tokenName + ">"
	end







	
	public String toString() 
		return tokenName + ":" + type
	end
end
