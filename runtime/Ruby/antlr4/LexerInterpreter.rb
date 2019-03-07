class LexerInterpreter
  extends Lexer
  protected final String grammarFileName
  protected final ATN atn

  @Deprecated
  protected final String[] tokenNames
  protected final String[] ruleNames
  protected final String[] channelNames
  protected final String[] modeNames


  private final Vocabulary vocabulary

  protected final DFA[] _decisionToDFA
  protected final PredictionContextCache _sharedContextCache =
                                             new PredictionContextCache()

  @Deprecated
  public LexerInterpreter(String grammarFileName, Collection < String > tokenNames, Collection < String > ruleNames, Collection < String > modeNames, ATN atn, CharStream input)
  this(grammarFileName, VocabularyImpl.fromTokenNames(tokenNames.toArray(new String[tokenNames.size()])), ruleNames, new ArrayList < String > (), modeNames, atn, input)
end

@Deprecated
public LexerInterpreter(String grammarFileName, Vocabulary vocabulary, Collection < String > ruleNames, Collection < String > modeNames, ATN atn, CharStream input)
this(grammarFileName, vocabulary, ruleNames, new ArrayList < String > (), modeNames, atn, input)
end

public LexerInterpreter(String grammarFileName, Vocabulary vocabulary, Collection < String > ruleNames, Collection < String > channelNames, Collection < String > modeNames, ATN atn, CharStream input)
super(input)

if (atn.grammarType != ATNType.LEXER)
  throw new IllegalArgumentException("The ATN must be a lexer ATN.")
end

this.grammarFileName = grammarFileName
this.atn = atn
this.tokenNames = new String[atn.maxTokenType]
for (int i = 0 i < tokenNames.length
  i + +)
  tokenNames[i] = vocabulary.getDisplayName(i)
end

this.ruleNames = ruleNames.toArray(new String[ruleNames.size()])
this.channelNames = channelNames.toArray(new String[channelNames.size()])
this.modeNames = modeNames.toArray(new String[modeNames.size()])
this.vocabulary = vocabulary

this._decisionToDFA = new DFA[atn.getNumberOfDecisions()]
for (int i = 0 i < _decisionToDFA.length
  i + +)
  _decisionToDFA[i] = new DFA(atn.getDecisionState(i), i)
end
this._interp = new LexerATNSimulator(this, atn, _decisionToDFA, _sharedContextCache)
end


public ATN getATN()
return atn
end


public String getGrammarFileName()
return grammarFileName
end


@Deprecated
public String[] getTokenNames()
return tokenNames
end


public String[] getRuleNames()
return ruleNames
end


public String[] getChannelNames()
return channelNames
end


public String[] getModeNames()
return modeNames
end


public Vocabulary getVocabulary()
if (vocabulary != null)
  return vocabulary
end

return super.getVocabulary()
end
end
