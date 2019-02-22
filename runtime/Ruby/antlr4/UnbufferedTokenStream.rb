











class UnbufferedTokenStream<T extends Token> implements TokenStream 
	protected TokenSource tokenSource






	protected Token[] tokens






	protected int n







	protected int p=0







	protected int numMarkers = 0




	protected Token lastToken





	protected Token lastTokenBufferStart









	protected int currentTokenIndex = 0

	public UnbufferedTokenStream(TokenSource tokenSource) 
		this(tokenSource, 256)
	end

	public UnbufferedTokenStream(TokenSource tokenSource, int bufferSize) 
		this.tokenSource = tokenSource
		tokens = new Token[bufferSize]
		n = 0
		fill(1) # prime the pump
	end

	
	public Token get(int i)  # get absolute index
		int bufferStartIndex = getBufferStartIndex()
		if (i < bufferStartIndex || i >= bufferStartIndex + n) 
			throw new IndexOutOfBoundsException("get("+i+") outside buffer: "+
			                    bufferStartIndex+".."+(bufferStartIndex+n))
		end
		return tokens[i - bufferStartIndex]
	end

	
	public Token LT(int i) 
		if ( i==-1 ) 
			return lastToken
		end

		sync(i)
        int index = p + i - 1
        if ( index < 0 ) 
			throw new IndexOutOfBoundsException("LT("+i+") gives negative index")
		end

		if ( index >= n ) 
			assert n > 0 && tokens[n-1].getType() == Token::EOF
			return tokens[n-1]
		end

		return tokens[index]
	end

	
	public int LA(int i) 
		return LT(i).getType()
	end

	
	public TokenSource getTokenSource() 
		return tokenSource
	end


	
	public String getText() 
		return ""
	end


	
	public String getText(RuleContext ctx) 
		return getText(ctx.getSourceInterval())
	end


	
	public String getText(Token start, Token stop) 
		return getText(Interval.of(start.getTokenIndex(), stop.getTokenIndex()))
	end

	
	public void consume() 
		if (LA(1) == Token::EOF)
			throw new IllegalStateException("cannot consume EOF")
		end

		# buf always has at least tokens[p==0] in this method due to ctor
		lastToken = tokens[p]   # track last token for LT(-1)

		# if we're at last token and no markers, opportunity to flush buffer
		if ( p == n-1 && numMarkers==0 ) 
			n = 0
			p = -1 # p++ will leave this at 0
			lastTokenBufferStart = lastToken
		end

		p++
		currentTokenIndex++
		sync(1)
	end





	protected void sync(int want) 
		int need = (p+want-1) - n + 1 # how many more elements we need?
		if ( need > 0 ) 
			fill(need)
		end
	end






	protected int fill(int n) 
		for (int i=0 i<n i++) 
			if (this.n > 0 && tokens[this.n-1].getType() == Token::EOF)
				return i
			end

			Token t = tokenSource.nextToken()
			add(t)
		end

		return n
	end

	protected void add(Token t) 
		if ( n>=tokens.length ) 
			tokens = Arrays.copyOf(tokens, tokens.length * 2)
		end

		if (t instanceof WritableToken) 
			((WritableToken)t).setTokenIndex(getBufferStartIndex() + n)
		end

		tokens[n++] = t
	end








	
	public int mark() 
		if (numMarkers == 0) 
			lastTokenBufferStart = lastToken
		end

		int mark = -numMarkers - 1
		numMarkers++
		return mark
	end

	
	public void release(int marker) 
		int expectedMark = -numMarkers
		if ( marker!=expectedMark ) 
			throw new IllegalStateException("release() called with an invalid marker.")
		end

		numMarkers--
		if ( numMarkers==0 )  # can we release buffer?
			if (p > 0) 
				# Copy tokens[p]..tokens[n-1] to tokens[0]..tokens[(n-1)-p], reset ptrs
				# p is last valid token move nothing if p==n as we have no valid char
				System.arraycopy(tokens, p, tokens, 0, n - p) # shift n-p tokens from p to 0
				n = n - p
				p = 0
			end

			lastTokenBufferStart = lastToken
		end
	end

	
	public int index() 
		return currentTokenIndex
	end

	
	public void seek(int index)  # seek to absolute index
		if (index == currentTokenIndex) 
			return
		end

		if (index > currentTokenIndex) 
			sync(index - currentTokenIndex)
			index = Math.min(index, getBufferStartIndex() + n - 1)
		end

		int bufferStartIndex = getBufferStartIndex()
		int i = index - bufferStartIndex
		if ( i < 0 ) 
			throw new IllegalArgumentException("cannot seek to negative index " + index)
		end
		else if (i >= n) 
			throw new UnsupportedOperationException("seek to index outside buffer: "+
													index+" not in "+ bufferStartIndex +".."+(bufferStartIndex +n))
		end

		p = i
		currentTokenIndex = index
		if (p == 0) 
			lastToken = lastTokenBufferStart
		end
		else 
			lastToken = tokens[p-1]
		end
	end

	
	public int size() 
		throw new UnsupportedOperationException("Unbuffered stream cannot know its size")
	end

	
	public String getSourceName() 
		return tokenSource.getSourceName()
	end


	
	public String getText(Interval interval) 
		int bufferStartIndex = getBufferStartIndex()
		int bufferStopIndex = bufferStartIndex + tokens.length - 1

		int start = interval.a
		int stop = interval.b
		if (start < bufferStartIndex || stop > bufferStopIndex) 
			throw new UnsupportedOperationException("interval "+interval+" not in token buffer window: "+
													bufferStartIndex+".."+bufferStopIndex)
		end

		int a = start - bufferStartIndex
		int b = stop - bufferStartIndex

		StringBuilder buf = StringBuilder.new()
		for (int i = a i <= b i++) 
			Token t = tokens[i]
			buf.append(t.getText())
		end

		return buf.to_s()
	end

	protected final int getBufferStartIndex() 
		return currentTokenIndex - p
	end
end
