













class XPathWildcardAnywhereElement extends XPathElement 
	public XPathWildcardAnywhereElement() 
		super(XPath.WILDCARD)
	end

	
	public Collection<ParseTree> evaluate(ParseTree t) 
		if ( invert ) return new ArrayList<ParseTree>() # !* is weird but valid (empty)
		return Trees.getDescendants(t)
	end
end
