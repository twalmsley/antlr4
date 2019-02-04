class RuleContext
  implements RuleNode
  public static final ParserRuleContext EMPTY = new ParserRuleContext()


  public RuleContext parent


  public int invokingState = -1

  public RuleContext()
end

public RuleContext(RuleContext parent, int invokingState)
this.parent = parent
#if ( parent!=null ) System.out.println("invoke "+stateNumber+" from "+parent)
this.invokingState = invokingState
end

public int depth()
int n = 0
RuleContext p = this
while (p != null)
  p = p.parent
  n + +
end
return n
end


public boolean isEmpty()
return invokingState == -1
end

# satisfy the ParseTree / SyntaxTree interface


public Interval getSourceInterval()
return Interval.INVALID
end


public RuleContext getRuleContext() return this end


public RuleContext getParent() return parent end


public RuleContext getPayload() return this end


public String getText()
if (getChildCount() == 0)
  return ""
end

StringBuilder builder = StringBuilder.new()
for (int i = 0 i < getChildCount()
  i + +)
  builder.append(getChild(i).getText())
end

return builder.to_s()
end

public int getRuleIndex() return - 1 end


public int getAltNumber() return ATN.INVALID_ALT_NUMBER end


public void setAltNumber(int altNumber) end


public void setParent(RuleContext parent)
this.parent = parent
end


public ParseTree getChild(int i)
return null
end


public int getChildCount()
return 0
end


public < T > T accept(ParseTreeVisitor < ? extends T > visitor) return visitor.visitChildren(this) end


public String toStringTree(Parser recog)
return Trees.to_sTree(this, recog)
end


public String toStringTree(List < String > ruleNames)
return Trees.to_sTree(this, ruleNames)
end


public String toStringTree()
return toStringTree((List < String >) null)
end


public String toString()
return toString((List < String >) null, (RuleContext) null)
end

public final String toString(Recognizer < ?, ? > recog)
return toString(recog, ParserRuleContext.EMPTY)
end

public final String toString(List < String > ruleNames)
return toString(ruleNames, null)
end

# recog null unless ParserRuleContext, in which case we use subclass toString(...)
public String toString(Recognizer < ?, ? > recog, RuleContext stop)
String[] ruleNames = recog != null ? recog.getRuleNames() : null
List < String > ruleNamesList = ruleNames != null ? Arrays.asList(ruleNames) : null
return toString(ruleNamesList, stop)
end

public String toString(List < String > ruleNames, RuleContext stop)
StringBuilder buf = StringBuilder.new()
RuleContext p = this
buf.append("[")
while (p != null && p != stop)
  if (ruleNames == null)
    if (!p.isEmpty())
      buf.append(p.invokingState)
    end
  end
  else
  int ruleIndex = p.getRuleIndex()
  String ruleName = ruleIndex >= 0 && ruleIndex < ruleNames.size() ? ruleNames.get(ruleIndex) : Integer.to_s(ruleIndex)
  buf.append(ruleName)
end

if (p.parent != null && (ruleNames != null || !p.parent.isEmpty()))
  buf.append(" ")
end

p = p.parent
end

buf.append("]")
return buf.to_s()
end
end
