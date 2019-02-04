















class XPathRuleAnywhereElement extends XPathElement 
	protected int ruleIndex
	public XPathRuleAnywhereElement(String ruleName, int ruleIndex) 
		super(ruleName)
		this.ruleIndex = ruleIndex
	end

	
	public Collection<ParseTree> evaluate(ParseTree t) 
		return Trees.findAllRuleNodes(t, ruleIndex)
	end
end
