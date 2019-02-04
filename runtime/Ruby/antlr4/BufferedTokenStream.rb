


























class BufferedTokenStream implements TokenStream 



    protected TokenSource tokenSource






    protected List<Token> tokens = new ArrayList<Token>(100)












    protected int p = -1














	protected boolean fetchedEOF

    public BufferedTokenStream(TokenSource tokenSource) 
		if (tokenSource == null) 
			throw new NullPointerException("tokenSource cannot be null")
		end
        this.tokenSource = tokenSource
    end

    
    public TokenSource getTokenSource()  return tokenSource end

	
	public int index()  return p end

    
    public int mark() 
		return 0
	end

	
	public void release(int marker) 
		# no resources to release
	end








	@Deprecated
    public void reset() 
        seek(0)
    end

    
    public void seek(int index) 
        lazyInit()
        p = adjustSeekIndex(index)
    end

    
    public int size()  return tokens.size() end

    
    public void consume() 
		boolean skipEofCheck
		if (p >= 0) 
			if (fetchedEOF) 
				# the last token in tokens is EOF. skip check if p indexes any
				# fetched token except the last.
				skipEofCheck = p < tokens.size() - 1
			end
			else 
				# no EOF token in tokens. skip check if p indexes a fetched token.
				skipEofCheck = p < tokens.size()
			end
		end
		else 
			# not yet initialized
			skipEofCheck = false
		end

		if (!skipEofCheck && LA(1) == EOF) 
			throw new IllegalStateException("cannot consume EOF")
		end

		if (sync(p + 1)) 
			p = adjustSeekIndex(p + 1)
		end
    end







    protected boolean sync(int i) 
		assert i >= 0
        int n = i - tokens.size() + 1 # how many more elements we need?
        #System.out.println("sync("+i+") needs "+n)
        if ( n > 0 ) 
			int fetched = fetch(n)
			return fetched >= n
		end

		return true
    end





    protected int fetch(int n) 
		if (fetchedEOF) 
			return 0
		end

        for (int i = 0 i < n i++) 
            Token t = tokenSource.nextToken()
            if ( t instanceof WritableToken ) 
                ((WritableToken)t).setTokenIndex(tokens.size())
            end
            tokens.add(t)
            if ( t.getType()==Token.EOF ) 
				fetchedEOF = true
				return i + 1
			end
        end

		return n
    end

    
    public Token get(int i) 
        if ( i < 0 || i >= tokens.size() ) 
            throw new IndexOutOfBoundsException("token index "+i+" out of range 0.."+(tokens.size()-1))
        end
        return tokens.get(i)
    end


	public List<Token> get(int start, int stop) 
		if ( start<0 || stop<0 ) return null
		lazyInit()
		List<Token> subset = new ArrayList<Token>()
		if ( stop>=tokens.size() ) stop = tokens.size()-1
		for (int i = start i <= stop i++) 
			Token t = tokens.get(i)
			if ( t.getType()==Token.EOF ) break
			subset.add(t)
		end
		return subset
	end

	
	public int LA(int i)  return LT(i).getType() end

    protected Token LB(int k) 
        if ( (p-k)<0 ) return null
        return tokens.get(p-k)
    end


    
    public Token LT(int k) 
        lazyInit()
        if ( k==0 ) return null
        if ( k < 0 ) return LB(-k)

		int i = p + k - 1
		sync(i)
        if ( i >= tokens.size() )  # return EOF token
            # EOF must be last token
            return tokens.get(tokens.size()-1)
        end
#		if ( i>range ) range = i
        return tokens.get(i)
    end














	protected int adjustSeekIndex(int i) 
		return i
	end

	protected final void lazyInit() 
		if (p == -1) 
			setup()
		end
	end

    protected void setup() 
		sync(0)
		p = adjustSeekIndex(0)
	end


    public void setTokenSource(TokenSource tokenSource) 
        this.tokenSource = tokenSource
        tokens.clear()
        p = -1
        fetchedEOF = false
    end

    public List<Token> getTokens()  return tokens end

    public List<Token> getTokens(int start, int stop) 
        return getTokens(start, stop, null)
    end





    public List<Token> getTokens(int start, int stop, Set<Integer> types) 
        lazyInit()
		if ( start<0 || stop>=tokens.size() ||
			 stop<0  || start>=tokens.size() )
		
			throw new IndexOutOfBoundsException("start "+start+" or stop "+stop+
												" not in 0.."+(tokens.size()-1))
		end
        if ( start>stop ) return null

        # list = tokens[start:stop]:T t, t.getType() in typesend
        List<Token> filteredTokens = new ArrayList<Token>()
        for (int i=start i<=stop i++) 
            Token t = tokens.get(i)
            if ( types==null || types.contains(t.getType()) ) 
                filteredTokens.add(t)
            end
        end
        if ( filteredTokens.isEmpty() ) 
            filteredTokens = null
        end
        return filteredTokens
    end

    public List<Token> getTokens(int start, int stop, int ttype) 
		HashSet<Integer> s = new HashSet<Integer>(ttype)
		s.add(ttype)
		return getTokens(start,stop, s)
    end







	protected int nextTokenOnChannel(int i, int channel) 
		sync(i)
		if (i >= size()) 
			return size() - 1
		end

		Token token = tokens.get(i)
		while ( token.getChannel()!=channel ) 
			if ( token.getType()==Token.EOF ) 
				return i
			end

			i++
			sync(i)
			token = tokens.get(i)
		end

		return i
	end











	protected int previousTokenOnChannel(int i, int channel) 
		sync(i)
		if (i >= size()) 
			# the EOF token is on every channel
			return size() - 1
		end

		while (i >= 0) 
			Token token = tokens.get(i)
			if (token.getType() == Token.EOF || token.getChannel() == channel) 
				return i
			end

			i--
		end

		return i
	end





	public List<Token> getHiddenTokensToRight(int tokenIndex, int channel) 
		lazyInit()
		if ( tokenIndex<0 || tokenIndex>=tokens.size() ) 
			throw new IndexOutOfBoundsException(tokenIndex+" not in 0.."+(tokens.size()-1))
		end

		int nextOnChannel =
			nextTokenOnChannel(tokenIndex + 1, Lexer.DEFAULT_TOKEN_CHANNEL)
		int to
		int from = tokenIndex+1
		# if none onchannel to right, nextOnChannel=-1 so set to = last token
		if ( nextOnChannel == -1 ) to = size()-1
		else to = nextOnChannel

		return filterForChannel(from, to, channel)
	end





	public List<Token> getHiddenTokensToRight(int tokenIndex) 
		return getHiddenTokensToRight(tokenIndex, -1)
	end





	public List<Token> getHiddenTokensToLeft(int tokenIndex, int channel) 
		lazyInit()
		if ( tokenIndex<0 || tokenIndex>=tokens.size() ) 
			throw new IndexOutOfBoundsException(tokenIndex+" not in 0.."+(tokens.size()-1))
		end

		if (tokenIndex == 0) 
			# obviously no tokens can appear before the first token
			return null
		end

		int prevOnChannel =
			previousTokenOnChannel(tokenIndex - 1, Lexer.DEFAULT_TOKEN_CHANNEL)
		if ( prevOnChannel == tokenIndex - 1 ) return null
		# if none onchannel to left, prevOnChannel=-1 then from=0
		int from = prevOnChannel+1
		int to = tokenIndex-1

		return filterForChannel(from, to, channel)
	end




	public List<Token> getHiddenTokensToLeft(int tokenIndex) 
		return getHiddenTokensToLeft(tokenIndex, -1)
	end

	protected List<Token> filterForChannel(int from, int to, int channel) 
		List<Token> hidden = new ArrayList<Token>()
		for (int i=from i<=to i++) 
			Token t = tokens.get(i)
			if ( channel==-1 ) 
				if ( t.getChannel()!= Lexer.DEFAULT_TOKEN_CHANNEL ) hidden.add(t)
			end
			else 
				if ( t.getChannel()==channel ) hidden.add(t)
			end
		end
		if ( hidden.size()==0 ) return null
		return hidden
	end

	
    public String getSourceName() 	return tokenSource.getSourceName()	end



	
	public String getText() 
		return getText(Interval.of(0,size()-1))
	end

	
	public String getText(Interval interval) 
		int start = interval.a
		int stop = interval.b
		if ( start<0 || stop<0 ) return ""
		fill()
        if ( stop>=tokens.size() ) stop = tokens.size()-1

		StringBuilder buf = StringBuilder.new()
		for (int i = start i <= stop i++) 
			Token t = tokens.get(i)
			if ( t.getType()==Token.EOF ) break
			buf.append(t.getText())
		end
		return buf.to_s()
    end


	
	public String getText(RuleContext ctx) 
		return getText(ctx.getSourceInterval())
	end


    
    public String getText(Token start, Token stop) 
        if ( start!=null && stop!=null ) 
            return getText(Interval.of(start.getTokenIndex(), stop.getTokenIndex()))
        end

		return ""
    end


    public void fill() 
        lazyInit()
		final int blockSize = 1000
		while (true) 
			int fetched = fetch(blockSize)
			if (fetched < blockSize) 
				return
			end
		end
    end
end
