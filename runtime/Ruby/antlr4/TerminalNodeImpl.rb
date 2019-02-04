












class TerminalNodeImpl implements TerminalNode 
	public Token symbol
	public ParseTree parent

	public TerminalNodeImpl(Token symbol) 	this.symbol = symbol	end

	
	public ParseTree getChild(int i) return nullend

	
	public Token getSymbol() return symbolend

	
	public ParseTree getParent()  return parent end

	
	public void setParent(RuleContext parent) 
		this.parent = parent
	end

	
	public Token getPayload()  return symbol end

	
	public Interval getSourceInterval() 
		if ( symbol ==null ) return Interval.INVALID

		int tokenIndex = symbol.getTokenIndex()
		return new Interval(tokenIndex, tokenIndex)
	end

	
	public int getChildCount()  return 0 end

	
	public <T> T accept(ParseTreeVisitor<? extends T> visitor) 
		return visitor.visitTerminal(this)
	end

	
	public String getText()  return symbol.getText() end

	
	public String toStringTree(Parser parser) 
		return toString()
	end

	
	public String toString() 
			if ( symbol.getType() == Token.EOF ) return "<EOF>"
			return symbol.getText()
	end

	
	public String toStringTree() 
		return toString()
	end
end
