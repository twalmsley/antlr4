












class XPathTokenAnywhereElement extends XPathElement 
	protected int tokenType
	public XPathTokenAnywhereElement(String tokenName, int tokenType) 
		super(tokenName)
		this.tokenType = tokenType
	end

	
	public Collection<ParseTree> evaluate(ParseTree t) 
		return Trees.findAllTokenNodes(t, tokenType)
	end
end
