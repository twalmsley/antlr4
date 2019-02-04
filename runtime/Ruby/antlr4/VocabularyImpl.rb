














class VocabularyImpl implements Vocabulary 
	private static final String[] EMPTY_NAMES = new String[0]









	public static final VocabularyImpl EMPTY_VOCABULARY = new VocabularyImpl(EMPTY_NAMES, EMPTY_NAMES, EMPTY_NAMES)


	private final String[] literalNames

	private final String[] symbolicNames

	private final String[] displayNames

	private final int maxTokenType













	public VocabularyImpl(String[] literalNames, String[] symbolicNames) 
		this(literalNames, symbolicNames, null)
	end


















	public VocabularyImpl(String[] literalNames, String[] symbolicNames, String[] displayNames) 
		this.literalNames = literalNames != null ? literalNames : EMPTY_NAMES
		this.symbolicNames = symbolicNames != null ? symbolicNames : EMPTY_NAMES
		this.displayNames = displayNames != null ? displayNames : EMPTY_NAMES
		# See note here on -1 part: https:#github.com/antlr/antlr4/pull/1146
		this.maxTokenType =
			Math.max(this.displayNames.length,
					 Math.max(this.literalNames.length, this.symbolicNames.length)) - 1
	end















	public static Vocabulary fromTokenNames(String[] tokenNames) 
		if (tokenNames == null || tokenNames.length == 0) 
			return EMPTY_VOCABULARY
		end

		String[] literalNames = Arrays.copyOf(tokenNames, tokenNames.length)
		String[] symbolicNames = Arrays.copyOf(tokenNames, tokenNames.length)
		for (int i = 0 i < tokenNames.length i++) 
			String tokenName = tokenNames[i]
			if (tokenName == null) 
				continue
			end

			if (!tokenName.isEmpty()) 
				char firstChar = tokenName.charAt(0)
				if (firstChar == '\'') 
					symbolicNames[i] = null
					continue
				end
				else if (Character.isUpperCase(firstChar)) 
					literalNames[i] = null
					continue
				end
			end

			# wasn't a literal or symbolic name
			literalNames[i] = null
			symbolicNames[i] = null
		end

		return new VocabularyImpl(literalNames, symbolicNames, tokenNames)
	end

	
	public int getMaxTokenType() 
		return maxTokenType
	end

	
	public String getLiteralName(int tokenType) 
		if (tokenType >= 0 && tokenType < literalNames.length) 
			return literalNames[tokenType]
		end

		return null
	end

	
	public String getSymbolicName(int tokenType) 
		if (tokenType >= 0 && tokenType < symbolicNames.length) 
			return symbolicNames[tokenType]
		end

		if (tokenType == Token.EOF) 
			return "EOF"
		end

		return null
	end

	
	public String getDisplayName(int tokenType) 
		if (tokenType >= 0 && tokenType < displayNames.length) 
			String displayName = displayNames[tokenType]
			if (displayName != null) 
				return displayName
			end
		end

		String literalName = getLiteralName(tokenType)
		if (literalName != null) 
			return literalName
		end

		String symbolicName = getSymbolicName(tokenType)
		if (symbolicName != null) 
			return symbolicName
		end

		return Integer.to_s(tokenType)
	end
end
