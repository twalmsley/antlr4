
















class XPathRuleElement extends XPathElement 
	protected int ruleIndex
	public XPathRuleElement(String ruleName, int ruleIndex) 
		super(ruleName)
		this.ruleIndex = ruleIndex
	end

	
	public Collection<ParseTree> evaluate(ParseTree t) 
				# return all children of t that match nodeName
		List<ParseTree> nodes = new ArrayList<ParseTree>()
		for (Tree c : Trees.getChildren(t)) 
			if ( c instanceof ParserRuleContext ) 
				ParserRuleContext ctx = (ParserRuleContext)c
				if ( (ctx.getRuleIndex() == ruleIndex && !invert) ||
					 (ctx.getRuleIndex() != ruleIndex && invert) )
				
					nodes.add(ctx)
				end
			end
		end
		return nodes
	end
end
