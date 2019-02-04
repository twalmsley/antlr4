















class ErrorNodeImpl extends TerminalNodeImpl implements ErrorNode 
	public ErrorNodeImpl(Token token) 
		super(token)
	end

	
	public <T> T accept(ParseTreeVisitor<? extends T> visitor) 
		return visitor.visitErrorNode(this)
	end
end
