
















class ParseTreeMatch 



	private final ParseTree tree




	private final ParseTreePattern pattern




	private final MultiMap<String, ParseTree> labels




	private final ParseTree mismatchedNode
















	public ParseTreeMatch(ParseTree tree, ParseTreePattern pattern, MultiMap<String, ParseTree> labels, ParseTree mismatchedNode) 
		if (tree == null) 
			throw new IllegalArgumentException("tree cannot be null")
		end

		if (pattern == null) 
			throw new IllegalArgumentException("pattern cannot be null")
		end

		if (labels == null) 
			throw new IllegalArgumentException("labels cannot be null")
		end

		this.tree = tree
		this.pattern = pattern
		this.labels = labels
		this.mismatchedNode = mismatchedNode
	end


















	public ParseTree get(String label) 
		List<ParseTree> parseTrees = labels.get(label)
		if ( parseTrees==null || parseTrees.size()==0 ) 
			return null
		end

		return parseTrees.get( parseTrees.size()-1 ) # return last if multiple
	end

























	public List<ParseTree> getAll(String label) 
		List<ParseTree> nodes = labels.get(label)
		if ( nodes==null ) 
			return Collections.emptyList()
		end

		return nodes
	end












	public MultiMap<String, ParseTree> getLabels() 
		return labels
	end








	public ParseTree getMismatchedNode() 
		return mismatchedNode
	end







	public boolean succeeded() 
		return mismatchedNode == null
	end







	public ParseTreePattern getPattern() 
		return pattern
	end







	public ParseTree getTree() 
		return tree
	end




	
	public String toString() 
		return String.format(
			"Match %s found %d labels",
			succeeded() ? "succeeded" : "failed",
			getLabels().size())
	end
end
