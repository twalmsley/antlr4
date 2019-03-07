class ParseTreePattern


  private final int patternRuleIndex


  private final String pattern


  private final ParseTree patternTree


  private final ParseTreePatternMatcher matcher


  public ParseTreePattern(ParseTreePatternMatcher matcher,
                                                  String pattern, int patternRuleIndex, ParseTree patternTree)

  this.matcher = matcher
  this.patternRuleIndex = patternRuleIndex
  this.pattern = pattern
  this.patternTree = patternTree
end


public ParseTreeMatch match(ParseTree tree)
return matcher.match(tree, this)
end


public boolean matches(ParseTree tree)
return matcher.match(tree, this).succeeded()
end


public List < ParseTreeMatch > findAll(ParseTree tree, xpath)
Collection < ParseTree > subtrees = XPath.findAll(tree, xpath, matcher.getParser())
List < ParseTreeMatch > matches = new ArrayList < ParseTreeMatch > ()
for (ParseTree t :
  subtrees)
  ParseTreeMatch match = match(t)
  if (match.succeeded())
    matches.add(match)
  end
end
return matches
end


public ParseTreePatternMatcher getMatcher()
return matcher
end


public String getPattern()
return pattern
end


public int getPatternRuleIndex()
return patternRuleIndex
end


public ParseTree getPatternTree()
return patternTree
end
end
