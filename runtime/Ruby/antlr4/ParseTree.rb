


















class ParseTree extends SyntaxTree 
	# the following methods narrow the return type they are not additional methods
	
	ParseTree getParent()
	
	ParseTree getChild(int i)

















	void setParent(RuleContext parent)


	<T> T accept(ParseTreeVisitor<? extends T> visitor)





	String getText()




	String toStringTree(Parser parser)
end
