

















class XPathLexer extends Lexer 
	public static final int
		TOKEN_REF=1, RULE_REF=2, ANYWHERE=3, ROOT=4, WILDCARD=5, BANG=6, ID=7,
		STRING=8
	public static String[] modeNames = 
		"DEFAULT_MODE"
	end

	public static final String[] ruleNames = 
		"ANYWHERE", "ROOT", "WILDCARD", "BANG", "ID", "NameChar", "NameStartChar",
		"STRING"
	end

	private static final String[] _LITERAL_NAMES = 
		null, null, null, "'#'", "'/'", "'*'", "'!'"
	end
	private static final String[] _SYMBOLIC_NAMES = 
		null, "TOKEN_REF", "RULE_REF", "ANYWHERE", "ROOT", "WILDCARD", "BANG",
		"ID", "STRING"
	end
	public static final Vocabulary VOCABULARY = new VocabularyImpl(_LITERAL_NAMES, _SYMBOLIC_NAMES)




	@Deprecated
	public static final String[] tokenNames
	static 
		tokenNames = new String[_SYMBOLIC_NAMES.length]
		for (int i = 0 i < tokenNames.length i++) 
			tokenNames[i] = VOCABULARY.getLiteralName(i)
			if (tokenNames[i] == null) 
				tokenNames[i] = VOCABULARY.getSymbolicName(i)
			end

			if (tokenNames[i] == null) 
				tokenNames[i] = "<INVALID>"
			end
		end
	end

	
	public String getGrammarFileName()  return "XPathLexer.g4" end

	
	public String[] getRuleNames()  return ruleNames end

	
	public String[] getModeNames()  return modeNames end

	
	@Deprecated
	public String[] getTokenNames() 
		return tokenNames
	end

	
	public Vocabulary getVocabulary() 
		return VOCABULARY
	end

	
	public ATN getATN() 
		return null
	end

	protected int line = 1
	protected int charPositionInLine = 0

	public XPathLexer(CharStream input) 
		super(input)
	end

	
	public Token nextToken() 
		_tokenStartCharIndex = _input.index()
		CommonToken t = null
		while ( t==null ) 
			switch ( _input.LA(1) ) 
				case '/':
					consume()
					if ( _input.LA(1)=='/' ) 
						consume()
						t = new CommonToken(ANYWHERE, "#")
					end
					else 
						t = new CommonToken(ROOT, "/")
					end
					break
				case '*':
					consume()
					t = new CommonToken(WILDCARD, "*")
					break
				case '!':
					consume()
					t = new CommonToken(BANG, "!")
					break
				case '\'':
					String s = matchString()
					t = new CommonToken(STRING, s)
					break
				case CharStream.EOF :
					return new CommonToken(EOF, "<EOF>")
				default:
					if ( isNameStartChar(_input.LA(1)) ) 
						String id = matchID()
						if ( Character.isUpperCase(id.charAt(0)) ) t = new CommonToken(TOKEN_REF, id)
						else t = new CommonToken(RULE_REF, id)
					end
					else 
						throw new LexerNoViableAltException(this, _input, _tokenStartCharIndex, null)
					end
					break
			end
		end
		t.setStartIndex(_tokenStartCharIndex)
		t.setCharPositionInLine(_tokenStartCharIndex)
		t.setLine(line)
		return t
	end

	public void consume() 
		int curChar = _input.LA(1)
		if ( curChar=='\n' ) 
			line++
			charPositionInLine=0
		end
		else 
			charPositionInLine++
		end
		_input.consume()
	end

	
	public int getCharPositionInLine() 
		return charPositionInLine
	end

	public String matchID() 
		int start = _input.index()
		consume() # drop start char
		while ( isNameChar(_input.LA(1)) ) 
			consume()
		end
		return _input.getText(Interval.of(start,_input.index()-1))
	end

	public String matchString() 
		int start = _input.index()
		consume() # drop first quote
		while ( _input.LA(1)!='\'' ) 
			consume()
		end
		consume() # drop last quote
		return _input.getText(Interval.of(start,_input.index()-1))
	end

	public boolean isNameChar(int c)  return Character.isUnicodeIdentifierPart(c) end

	public boolean isNameStartChar(int c)  return Character.isUnicodeIdentifierStart(c) end
end
