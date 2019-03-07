class InterpreterRuleContext
  extends ParserRuleContext

  protected int ruleIndex = -1

  public InterpreterRuleContext()
end


public InterpreterRuleContext(ParserRuleContext parent,
                                                int invokingStateNumber,
                                                    int ruleIndex)

super(parent, invokingStateNumber)
this.ruleIndex = ruleIndex
end


public int getRuleIndex()
return ruleIndex
end
end
