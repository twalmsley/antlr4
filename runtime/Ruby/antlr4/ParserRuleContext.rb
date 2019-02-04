








































class ParserRuleContext extends RuleContext 






	public List<ParseTree> children



















#	public List<Integer> states

	public Token start, stop





	public RecognitionException exception

	public ParserRuleContext()  end













	public void copyFrom(ParserRuleContext ctx) 
		this.parent = ctx.parent
		this.invokingState = ctx.invokingState

		this.start = ctx.start
		this.stop = ctx.stop

		# copy any error nodes to alt label node
		if ( ctx.children!=null ) 
			this.children = new ArrayList<>()
			# reset parent pointer for any error nodes
			for (ParseTree child : ctx.children) 
				if ( child instanceof ErrorNode ) 
					addChild((ErrorNode)child)
				end
			end
		end
	end

	public ParserRuleContext(ParserRuleContext parent, int invokingStateNumber) 
		super(parent, invokingStateNumber)
	end

	# Double dispatch methods for listeners

	public void enterRule(ParseTreeListener listener)  end
	public void exitRule(ParseTreeListener listener)  end












	public <T extends ParseTree> T addAnyChild(T t) 
		if ( children==null ) children = new ArrayList<>()
		children.add(t)
		return t
	end

	public RuleContext addChild(RuleContext ruleInvocation) 
		return addAnyChild(ruleInvocation)
	end


	public TerminalNode addChild(TerminalNode t) 
		t.setParent(this)
		return addAnyChild(t)
	end





	public ErrorNode addErrorNode(ErrorNode errorNode) 
		errorNode.setParent(this)
		return addAnyChild(errorNode)
	end






	@Deprecated
	public TerminalNode addChild(Token matchedToken) 
		TerminalNodeImpl t = new TerminalNodeImpl(matchedToken)
		addAnyChild(t)
		t.setParent(this)
		return t
	end






	@Deprecated
	public ErrorNode addErrorNode(Token badToken) 
		ErrorNodeImpl t = new ErrorNodeImpl(badToken)
		addAnyChild(t)
		t.setParent(this)
		return t
	end

#	public void trace(int s) 
#		if ( states==null ) states = new ArrayList<Integer>()
#		states.add(s)
#	end





	public void removeLastChild() 
		if ( children!=null ) 
			children.remove(children.size()-1)
		end
	end

	

	public ParserRuleContext getParent() 
		return (ParserRuleContext)super.getParent()
	end

	
	public ParseTree getChild(int i) 
		return children!=null && i>=0 && i<children.size() ? children.get(i) : null
	end

	public <T extends ParseTree> T getChild(Class<? extends T> ctxType, int i) 
		if ( children==null || i < 0 || i >= children.size() ) 
			return null
		end

		int j = -1 # what element have we found with ctxType?
		for (ParseTree o : children) 
			if ( ctxType.isInstance(o) ) 
				j++
				if ( j == i ) 
					return ctxType.cast(o)
				end
			end
		end
		return null
	end

	public TerminalNode getToken(int ttype, int i) 
		if ( children==null || i < 0 || i >= children.size() ) 
			return null
		end

		int j = -1 # what token with ttype have we found?
		for (ParseTree o : children) 
			if ( o instanceof TerminalNode ) 
				TerminalNode tnode = (TerminalNode)o
				Token symbol = tnode.getSymbol()
				if ( symbol.getType()==ttype ) 
					j++
					if ( j == i ) 
						return tnode
					end
				end
			end
		end

		return null
	end

	public List<TerminalNode> getTokens(int ttype) 
		if ( children==null ) 
			return Collections.emptyList()
		end

		List<TerminalNode> tokens = null
		for (ParseTree o : children) 
			if ( o instanceof TerminalNode ) 
				TerminalNode tnode = (TerminalNode)o
				Token symbol = tnode.getSymbol()
				if ( symbol.getType()==ttype ) 
					if ( tokens==null ) 
						tokens = new ArrayList<TerminalNode>()
					end
					tokens.add(tnode)
				end
			end
		end

		if ( tokens==null ) 
			return Collections.emptyList()
		end

		return tokens
	end

	public <T extends ParserRuleContext> T getRuleContext(Class<? extends T> ctxType, int i) 
		return getChild(ctxType, i)
	end

	public <T extends ParserRuleContext> List<T> getRuleContexts(Class<? extends T> ctxType) 
		if ( children==null ) 
			return Collections.emptyList()
		end

		List<T> contexts = null
		for (ParseTree o : children) 
			if ( ctxType.isInstance(o) ) 
				if ( contexts==null ) 
					contexts = new ArrayList<T>()
				end

				contexts.add(ctxType.cast(o))
			end
		end

		if ( contexts==null ) 
			return Collections.emptyList()
		end

		return contexts
	end

	
	public int getChildCount()  return children!=null ? children.size() : 0 end

	
	public Interval getSourceInterval() 
		if ( start == null ) 
			return Interval.INVALID
		end
		if ( stop==null || stop.getTokenIndex()<start.getTokenIndex() ) 
			return Interval.of(start.getTokenIndex(), start.getTokenIndex()-1) # empty
		end
		return Interval.of(start.getTokenIndex(), stop.getTokenIndex())
	end






	public Token getStart()  return start end





	public Token getStop()  return stop end


	public String toInfoString(Parser recognizer) 
		List<String> rules = recognizer.getRuleInvocationStack(this)
		Collections.reverse(rules)
		return "ParserRuleContext"+rules+"" +
			"start=" + start +
			", stop=" + stop +
			'end'
	end
end

