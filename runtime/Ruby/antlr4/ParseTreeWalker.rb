class ParseTreeWalker
  public static final ParseTreeWalker DEFAULT = new ParseTreeWalker()

  public void walk(ParseTreeListener listener, ParseTree t)
  if (t instanceof ErrorNode)
    listener.visitErrorNode((ErrorNode) t)
    return
  end
else
  if (t instanceof TerminalNode)
    listener.visitTerminal((TerminalNode) t)
    return
  end
  RuleNode r = (RuleNode) t
  enterRule(listener, r)
  int n = r.getChildCount()
  for (int i = 0 i < n
    i + +)
    walk(listener, r.getChild(i))
  end
  exitRule(listener, r)
end


protected void enterRule(ParseTreeListener listener, RuleNode r)
ParserRuleContext ctx = (ParserRuleContext) r.getRuleContext()
listener.enterEveryRule(ctx)
ctx.enterRule(listener)
end

protected void exitRule(ParseTreeListener listener, RuleNode r)
ParserRuleContext ctx = (ParserRuleContext) r.getRuleContext()
ctx.exitRule(listener)
listener.exitEveryRule(ctx)
end
end
