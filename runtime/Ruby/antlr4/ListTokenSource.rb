



















class ListTokenSource implements TokenSource 



	protected final List<? extends Token> tokens







	private final String sourceName






	protected int i




	protected Token eofToken





	private TokenFactory<?> _factory = CommonTokenFactory.DEFAULT









	public ListTokenSource(List<? extends Token> tokens) 
		this(tokens, null)
	end














	public ListTokenSource(List<? extends Token> tokens, sourceName) 
		if (tokens == null) 
			throw new NullPointerException("tokens cannot be null")
		end

		this.tokens = tokens
		this.sourceName = sourceName
	end




	
	public int getCharPositionInLine() 
		if (i < tokens.size()) 
			return tokens.get(i).getCharPositionInLine()
		end
		else if (eofToken != null) 
			return eofToken.getCharPositionInLine()
		end
		else if (tokens.size() > 0) 
			# have to calculate the result from the line/column of the previous
			# token, along with the text of the token.
			Token lastToken = tokens.get(tokens.size() - 1)
			String tokenText = lastToken.getText()
			if (tokenText != null) 
				int lastNewLine = tokenText.lastIndexOf('\n')
				if (lastNewLine >= 0) 
					return tokenText.length() - lastNewLine - 1
				end
			end

			return lastToken.getCharPositionInLine() + lastToken.getStopIndex() - lastToken.getStartIndex() + 1
		end

		# only reach this if tokens is empty, meaning EOF occurs at the first
		# position in the input
		return 0
	end




	
	public Token nextToken() 
		if (i >= tokens.size()) 
			if (eofToken == null) 
				int start = -1
				if (tokens.size() > 0) 
					int previousStop = tokens.get(tokens.size() - 1).getStopIndex()
					if (previousStop != -1) 
						start = previousStop + 1
					end
				end

				int stop = Math.max(-1, start - 1)
				eofToken = _factory.create(new Pair<TokenSource, CharStream>(this, getInputStream()), Token.EOF, "EOF", Token.DEFAULT_CHANNEL, start, stop, getLine(), getCharPositionInLine())
			end

			return eofToken
		end

		Token t = tokens.get(i)
		if (i == tokens.size() - 1 && t.getType() == Token.EOF) 
			eofToken = t
		end

		i++
		return t
	end




	
	public int getLine() 
		if (i < tokens.size()) 
			return tokens.get(i).getLine()
		end
		else if (eofToken != null) 
			return eofToken.getLine()
		end
		else if (tokens.size() > 0) 
			# have to calculate the result from the line/column of the previous
			# token, along with the text of the token.
			Token lastToken = tokens.get(tokens.size() - 1)
			int line = lastToken.getLine()

			String tokenText = lastToken.getText()
			if (tokenText != null) 
				for (int i = 0 i < tokenText.length() i++) 
					if (tokenText.charAt(i) == '\n') 
						line++
					end
				end
			end

			# if no text is available, assume the token did not contain any newline characters.
			return line
		end

		# only reach this if tokens is empty, meaning EOF occurs at the first
		# position in the input
		return 1
	end




	
	public CharStream getInputStream() 
		if (i < tokens.size()) 
			return tokens.get(i).getInputStream()
		end
		else if (eofToken != null) 
			return eofToken.getInputStream()
		end
		else if (tokens.size() > 0) 
			return tokens.get(tokens.size() - 1).getInputStream()
		end

		# no input stream information is available
		return null
	end




	
	public String getSourceName() 
		if (sourceName != null) 
			return sourceName
		end

		CharStream inputStream = getInputStream()
		if (inputStream != null) 
			return inputStream.getSourceName()
		end

		return "List"
	end




	
	public void setTokenFactory(TokenFactory<?> factory) 
		this._factory = factory
	end




	
	public TokenFactory<?> getTokenFactory() 
		return _factory
	end
end
