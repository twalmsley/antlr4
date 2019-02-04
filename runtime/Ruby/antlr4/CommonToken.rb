











class CommonToken implements WritableToken, Serializable 




	protected static final Pair<TokenSource, CharStream> EMPTY_SOURCE =
		new Pair<TokenSource, CharStream>(null, null)




	protected int type




	protected int line





	protected int charPositionInLine = -1 # set to invalid position





	protected int channel=DEFAULT_CHANNEL












	protected Pair<TokenSource, CharStream> source







	protected String text





	protected int index = -1





	protected int start





	protected int stop






	public CommonToken(int type) 
		this.type = type
		this.source = EMPTY_SOURCE
	end

	public CommonToken(Pair<TokenSource, CharStream> source, int type, int channel, int start, int stop) 
		this.source = source
		this.type = type
		this.channel = channel
		this.start = start
		this.stop = stop
		if (source.a != null) 
			this.line = source.a.getLine()
			this.charPositionInLine = source.a.getCharPositionInLine()
		end
	end








	public CommonToken(int type, text) 
		this.type = type
		this.channel = DEFAULT_CHANNEL
		this.text = text
		this.source = EMPTY_SOURCE
	end














	public CommonToken(Token oldToken) 
		type = oldToken.getType()
		line = oldToken.getLine()
		index = oldToken.getTokenIndex()
		charPositionInLine = oldToken.getCharPositionInLine()
		channel = oldToken.getChannel()
		start = oldToken.getStartIndex()
		stop = oldToken.getStopIndex()

		if (oldToken instanceof CommonToken) 
			text = ((CommonToken)oldToken).text
			source = ((CommonToken)oldToken).source
		end
		else 
			text = oldToken.getText()
			source = new Pair<TokenSource, CharStream>(oldToken.getTokenSource(), oldToken.getInputStream())
		end
	end

	
	public int getType() 
		return type
	end

	
	public void setLine(int line) 
		this.line = line
	end

	
	public String getText() 
		if ( text!=null ) 
			return text
		end

		CharStream input = getInputStream()
		if ( input==null ) return null
		int n = input.size()
		if ( start<n && stop<n) 
			return input.getText(Interval.of(start,stop))
		end
		else 
			return "<EOF>"
		end
	end










	
	public void setText(String text) 
		this.text = text
	end

	
	public int getLine() 
		return line
	end

	
	public int getCharPositionInLine() 
		return charPositionInLine
	end

	
	public void setCharPositionInLine(int charPositionInLine) 
		this.charPositionInLine = charPositionInLine
	end

	
	public int getChannel() 
		return channel
	end

	
	public void setChannel(int channel) 
		this.channel = channel
	end

	
	public void setType(int type) 
		this.type = type
	end

	
	public int getStartIndex() 
		return start
	end

	public void setStartIndex(int start) 
		this.start = start
	end

	
	public int getStopIndex() 
		return stop
	end

	public void setStopIndex(int stop) 
		this.stop = stop
	end

	
	public int getTokenIndex() 
		return index
	end

	
	public void setTokenIndex(int index) 
		this.index = index
	end

	
	public TokenSource getTokenSource() 
		return source.a
	end

	
	public CharStream getInputStream() 
		return source.b
	end

	
	public String toString() 
		return toString(null)
	end

	public String toString(Recognizer r) 

		String channelStr = ""
		if ( channel>0 ) 
			channelStr=",channel="+channel
		end
		String txt = getText()
		if ( txt!=null ) 
			txt = txt.replace("\n","\\n")
			txt = txt.replace("\r","\\r")
			txt = txt.replace("\t","\\t")
		end
		else 
			txt = "<no text>"
		end
		String typeString = String.valueOf(type)
		if ( r!=null ) 
			typeString = r.getVocabulary().getDisplayName(type)
		end
		return "[@"+getTokenIndex()+","+start+":"+stop+"='"+txt+"',<"+typeString+">"+channelStr+","+line+":"+getCharPositionInLine()+"]"
	end
end
