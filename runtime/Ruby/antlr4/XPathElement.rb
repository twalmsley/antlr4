











public abstract class XPathElement 
	protected String nodeName
	protected boolean invert




	public XPathElement(String nodeName) 
		this.nodeName = nodeName
	end





	public abstract Collection<ParseTree> evaluate(ParseTree t)

	
	public String toString() 
		String inv = invert ? "!" : ""
		return getClass().getSimpleName()+"["+inv+nodeName+"]"
	end
end
