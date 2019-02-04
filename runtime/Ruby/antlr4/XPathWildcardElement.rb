















class XPathWildcardElement extends XPathElement 
	public XPathWildcardElement() 
		super(XPath.WILDCARD)
	end

	
	public Collection<ParseTree> evaluate(final ParseTree t) 
		if ( invert ) return new ArrayList<ParseTree>() # !* is weird but valid (empty)
		List<ParseTree> kids = new ArrayList<ParseTree>()
		for (Tree c : Trees.getChildren(t)) 
			kids.add((ParseTree)c)
		end
		return kids
	end
end
