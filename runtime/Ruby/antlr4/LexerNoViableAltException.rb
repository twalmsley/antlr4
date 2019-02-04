













class LexerNoViableAltException extends RecognitionException 

	private final int startIndex


	private final ATNConfigSet deadEndConfigs

	public LexerNoViableAltException(Lexer lexer,
									 CharStream input,
									 int startIndex,
									 ATNConfigSet deadEndConfigs) 
		super(lexer, input, null)
		this.startIndex = startIndex
		this.deadEndConfigs = deadEndConfigs
	end

	public int getStartIndex() 
		return startIndex
	end


	public ATNConfigSet getDeadEndConfigs() 
		return deadEndConfigs
	end

	
	public CharStream getInputStream() 
		return (CharStream)super.getInputStream()
	end

	
	public String toString() 
		String symbol = ""
		if (startIndex >= 0 && startIndex < getInputStream().size()) 
			symbol = getInputStream().getText(Interval.of(startIndex,startIndex))
			symbol = Utils.escapeWhitespace(symbol, false)
		end

		return String.format(Locale.getDefault(), "%s('%s')", LexerNoViableAltException.class.getSimpleName(), symbol)
	end
end
