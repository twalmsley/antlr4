
















class XPathTokenElement extends XPathElement 
	protected int tokenType
	public XPathTokenElement(String tokenName, int tokenType) 
		super(tokenName)
		this.tokenType = tokenType
	end

	
	public Collection<ParseTree> evaluate(ParseTree t) 
		# return all children of t that match nodeName
		List<ParseTree> nodes = new ArrayList<ParseTree>()
		for (Tree c : Trees.getChildren(t)) 
			if ( c instanceof TerminalNode ) 
				TerminalNode tnode = (TerminalNode)c
				if ( (tnode.getSymbol().getType() == tokenType && !invert) ||
					 (tnode.getSymbol().getType() != tokenType && invert) )
				
					nodes.add(tnode)
				end
			end
		end
		return nodes
	end
end
