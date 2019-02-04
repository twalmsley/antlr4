































class CommonTokenStream extends BufferedTokenStream 







    protected int channel = Token.DEFAULT_CHANNEL







    public CommonTokenStream(TokenSource tokenSource) 
        super(tokenSource)
    end











    public CommonTokenStream(TokenSource tokenSource, int channel) 
        this(tokenSource)
        this.channel = channel
    end

	
	protected int adjustSeekIndex(int i) 
		return nextTokenOnChannel(i, channel)
	end

    
    protected Token LB(int k) 
        if ( k==0 || (p-k)<0 ) return null

        int i = p
        int n = 1
        # find k good tokens looking backwards
        while ( n<=k && i>0 ) 
            # skip off-channel tokens
            i = previousTokenOnChannel(i - 1, channel)
            n++
        end
        if ( i<0 ) return null
        return tokens.get(i)
    end

    
    public Token LT(int k) 
        #System.out.println("enter LT("+k+")")
        lazyInit()
        if ( k == 0 ) return null
        if ( k < 0 ) return LB(-k)
        int i = p
        int n = 1 # we know tokens[p] is a good one
        # find k good tokens
        while ( n<k ) 
            # skip off-channel tokens, but make sure to not look past EOF
			if (sync(i + 1)) 
				i = nextTokenOnChannel(i + 1, channel)
			end
            n++
        end
#		if ( i>range ) range = i
        return tokens.get(i)
    end


	public int getNumberOfOnChannelTokens() 
		int n = 0
		fill()
		for (int i = 0 i < tokens.size() i++) 
			Token t = tokens.get(i)
			if ( t.getChannel()==channel ) n++
			if ( t.getType()==Token.EOF ) break
		end
		return n
	end
end
