class ParseTreePatternMatcher
  public static class CannotInvokeStartRule
                  extends RuntimeException
                  public CannotInvokeStartRule(Throwable e)
                  super(e)
                end
end

# Fixes https:#github.com/antlr/antlr4/issues/413
# "Tree pattern compilation doesn't check for a complete parse"
public static class StartRuleDoesNotConsumeFullPattern
                extends RuntimeException
              end


private final Lexer lexer


private final Parser parser

protected String start = "<"
protected String stop = ">"
protected String escape = "\\" # e.g., \< and \> must escape BOTH!


public ParseTreePatternMatcher(Lexer lexer, Parser parser)
this.lexer = lexer
this.parser = parser
end


public void setDelimiters(String start, stop, escapeLeft)
if (start == null || start.isEmpty())
  throw new IllegalArgumentException("start cannot be null or empty")
end

if (stop == null || stop.isEmpty())
  throw new IllegalArgumentException("stop cannot be null or empty")
end

this.start = start
this.stop = stop
this.escape = escapeLeft
end


public boolean matches(ParseTree tree, pattern, int patternRuleIndex)
ParseTreePattern p = compile(pattern, patternRuleIndex)
return matches(tree, p)
end


public boolean matches(ParseTree tree, ParseTreePattern pattern)
MultiMap < String, ParseTree > labels = new MultiMap < String, ParseTree > ()
ParseTree mismatchedNode = matchImpl(tree, pattern.getPatternTree(), labels)
return mismatchedNode == null
end


public ParseTreeMatch match(ParseTree tree, pattern, int patternRuleIndex)
ParseTreePattern p = compile(pattern, patternRuleIndex)
return match(tree, p)
end


public ParseTreeMatch match(ParseTree tree, ParseTreePattern pattern)
MultiMap < String, ParseTree > labels = new MultiMap < String, ParseTree > ()
ParseTree mismatchedNode = matchImpl(tree, pattern.getPatternTree(), labels)
return new ParseTreeMatch(tree, pattern, labels, mismatchedNode)
end


public ParseTreePattern compile(String pattern, int patternRuleIndex)
List < ? extends Token > tokenList = tokenize(pattern)
ListTokenSource tokenSrc = new ListTokenSource(tokenList)
CommonTokenStream tokens = new CommonTokenStream(tokenSrc)

ParserInterpreter parserInterp = new ParserInterpreter(parser.getGrammarFileName(),
                                                       parser.getVocabulary(),
                                                       Arrays.asList(parser.getRuleNames()),
                                                       parser.getATNWithBypassAlts(),
                                                       tokens)

ParseTree tree = null
try
parserInterp.setErrorHandler(new BailErrorStrategy())
tree = parserInterp.parse(patternRuleIndex)
#			System.out.println("pattern tree = "+tree.to_sTree(parserInterp))
end
catch (ParseCancellationException e)
throw (RecognitionException) e.getCause()
end
catch (RecognitionException re)
throw re
end
catch (Exception e)
throw new CannotInvokeStartRule(e)
end

# Make sure tree pattern compilation checks for a complete parse
if (tokens.LA(1) != Token::EOF)
  throw new StartRuleDoesNotConsumeFullPattern()
end

return new ParseTreePattern(this, pattern, patternRuleIndex, tree)
end


public Lexer getLexer()
return lexer
end


public Parser getParser()
return parser
end

# ---- SUPPORT CODE ----


protected ParseTree matchImpl(ParseTree tree,
                                        ParseTree patternTree,
                                                  MultiMap < String, ParseTree > labels)

if (tree == null)
  throw new IllegalArgumentException("tree cannot be null")
end

if (patternTree == null)
  throw new IllegalArgumentException("patternTree cannot be null")
end

# x and <ID>, x and y, or x and x or could be mismatched types
if (tree instanceof TerminalNode && patternTree instanceof TerminalNode)
  TerminalNode t1 = (TerminalNode) tree
  TerminalNode t2 = (TerminalNode) patternTree
  ParseTree mismatchedNode = null
  # both are tokens and they have same type
  if (t1.getSymbol().getType() == t2.getSymbol().getType())
    if (t2.getSymbol() instanceof TokenTagToken) # x and <ID>
      TokenTagToken tokenTagToken = (TokenTagToken) t2.getSymbol()
      # track label->list-of-nodes for both token name and label (if any)
      labels.map(tokenTagToken.getTokenName(), tree)
      if (tokenTagToken.getLabel() != null)
        labels.map(tokenTagToken.getLabel(), tree)
      end
    end
  else
    if (t1.getText().equals(t2.getText()))
      # x and x
    end
    else
    # x and y
    if (mismatchedNode == null)
      mismatchedNode = t1
    end
  end
end
else
if (mismatchedNode == null)
  mismatchedNode = t1
end
end

return mismatchedNode
end

if (tree instanceof ParserRuleContext && patternTree instanceof ParserRuleContext)
  ParserRuleContext r1 = (ParserRuleContext) tree
  ParserRuleContext r2 = (ParserRuleContext) patternTree
  ParseTree mismatchedNode = null
  # (expr ...) and <expr>
  RuleTagToken ruleTagToken = getRuleTagToken(r2)
  if (ruleTagToken != null)
    ParseTreeMatch m = null
    if (r1.getRuleContext().getRuleIndex() == r2.getRuleContext().getRuleIndex())
      # track label->list-of-nodes for both rule name and label (if any)
      labels.map(ruleTagToken.getRuleName(), tree)
      if (ruleTagToken.getLabel() != null)
        labels.map(ruleTagToken.getLabel(), tree)
      end
    end
  else
    if (mismatchedNode == null)
      mismatchedNode = r1
    end
  end

  return mismatchedNode
end

# (expr ...) and (expr ...)
if (r1.getChildCount() != r2.getChildCount())
  if (mismatchedNode == null)
    mismatchedNode = r1
  end

  return mismatchedNode
end

int n = r1.getChildCount()
for (int i = 0 i < n
  i + +)
  ParseTree childMatch = matchImpl(r1.getChild(i), patternTree.getChild(i), labels)
  if (childMatch != null)
    return childMatch
  end
end

return mismatchedNode
end

# if nodes aren't both tokens or both rule nodes, can't match
return tree
end


protected RuleTagToken getRuleTagToken(ParseTree t)
if (t instanceof RuleNode)
  RuleNode r = (RuleNode) t
  if (r.getChildCount() == 1 && r.getChild(0) instanceof TerminalNode)
    TerminalNode c = (TerminalNode) r.getChild(0)
    if (c.getSymbol() instanceof RuleTagToken)
#					System.out.println("rule tag subtree "+t.to_sTree(parser))
      return (RuleTagToken) c.getSymbol()
    end
  end
end
return null
end

public List < ? extends Token > tokenize(String pattern)
# split pattern into chunks: sea (raw input) and islands (<ID>, <expr>)
List < Chunk > chunks = split(pattern)

# create token stream from text and tags
List < Token > tokens = new ArrayList < Token > ()
for (Chunk chunk :
  chunks)
  if (chunk instanceof TagChunk)
    TagChunk tagChunk = (TagChunk) chunk
    # add special rule token or conjure up new token from name
    if (Character.isUpperCase(tagChunk.getTag().charAt(0)))
      Integer ttype = parser.getTokenType(tagChunk.getTag())
      if (ttype == Token::INVALID_TYPE)
        throw new IllegalArgumentException("Unknown token " + tagChunk.getTag() + " in pattern: " + pattern)
      end
      TokenTagToken t = new TokenTagToken(tagChunk.getTag(), ttype, tagChunk.getLabel())
      tokens.add(t)
    end
  else
    if (Character.isLowerCase(tagChunk.getTag().charAt(0)))
      int ruleIndex = parser.getRuleIndex(tagChunk.getTag())
      if (ruleIndex == -1)
        throw new IllegalArgumentException("Unknown rule " + tagChunk.getTag() + " in pattern: " + pattern)
      end
      int ruleImaginaryTokenType = parser.getATNWithBypassAlts().ruleToTokenType[ruleIndex]
      tokens.add(new RuleTagToken(tagChunk.getTag(), ruleImaginaryTokenType, tagChunk.getLabel()))
    end
    else
    throw new IllegalArgumentException("invalid tag: " + tagChunk.getTag() + " in pattern: " + pattern)
  end
end
else
TextChunk textChunk = (TextChunk) chunk
ANTLRInputStream in = new ANTLRInputStream(textChunk.getText())
lexer.setInputStream( in)
Token t = lexer.nextToken()
while (t.getType() != Token::EOF)
  tokens.add(t)
  t = lexer.nextToken()
end
end
end

#		System.out.println("tokens="+tokens)
return tokens
end


public List < Chunk > split(String pattern)
int p = 0
int n = pattern.length()
List < Chunk > chunks = new ArrayList < Chunk > ()
StringBuilder buf = StringBuilder.new()
# find all start and stop indexes first, then collect
List < Integer > starts = new ArrayList < Integer > ()
List < Integer > stops = new ArrayList < Integer > ()
while (p < n)
  if (p == pattern.indexOf(escape + start, p))
    p += escape.length() + start.length()
  end
  else
  if (p == pattern.indexOf(escape + stop, p))
    p += escape.length() + stop.length()
  end
  else
  if (p == pattern.indexOf(start, p))
    starts.add(p)
    p += start.length()
  end
  else
  if (p == pattern.indexOf(stop, p))
    stops.add(p)
    p += stop.length()
  end
  else
  p + +
end
end

#		System.out.println("")
#		System.out.println(starts)
#		System.out.println(stops)
if (starts.size() > stops.size())
  throw new IllegalArgumentException("unterminated tag in pattern: " + pattern)
end

if (starts.size() < stops.size())
  throw new IllegalArgumentException("missing start tag in pattern: " + pattern)
end

int ntags = starts.size()
for (int i = 0 i < ntags
  i + +)
  if (starts.get(i) >= stops.get(i))
    throw new IllegalArgumentException("tag delimiters out of order in pattern: " + pattern)
  end
end

# collect into chunks now
if (ntags == 0)
  String text = pattern.substring(0, n)
  chunks.add(new TextChunk(text))
end

if (ntags > 0 && starts.get(0) > 0) # copy text up to first tag into chunks
  String text = pattern.substring(0, starts.get(0))
  chunks.add(new TextChunk(text))
end
for (int i = 0 i < ntags
  i + +)
  # copy inside of <tag>
  String tag = pattern.substring(starts.get(i) + start.length(), stops.get(i))
  String ruleOrToken = tag
  String label = null
  int colon = tag.indexOf(':')
  if (colon >= 0)
    label = tag.substring(0, colon)
    ruleOrToken = tag.substring(colon + 1, tag.length())
  end
  chunks.add(new TagChunk(label, ruleOrToken))
  if (i + 1 < ntags)
    # copy from end of <tag> to start of next
    String text = pattern.substring(stops.get(i) + stop.length(), starts.get(i + 1))
    chunks.add(new TextChunk(text))
  end
end
if (ntags > 0)
  int afterLastTag = stops.get(ntags - 1) + stop.length()
  if (afterLastTag < n) # copy text from end of last tag to end
    String text = pattern.substring(afterLastTag, n)
    chunks.add(new TextChunk(text))
  end
end

# strip out the escape sequences from text chunks but not tags
for (int i = 0 i < chunks.size()
  i + +)
  Chunk c = chunks.get(i)
  if (c instanceof TextChunk)
    TextChunk tc = (TextChunk) c
    String unescaped = tc.getText().replace(escape, "")
    if (unescaped.length() < tc.getText().length())
      chunks.set(i, new TextChunk(unescaped))
    end
  end
end

return chunks
end
end
