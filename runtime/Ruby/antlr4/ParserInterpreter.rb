class ParserInterpreter
  extends Parser
  protected final String grammarFileName
  protected final ATN atn

  protected final DFA[] decisionToDFA # not shared like it is for generated parsers
  protected final PredictionContextCache sharedContextCache = new PredictionContextCache()

  @Deprecated
  protected final String[] tokenNames
  protected final String[] ruleNames

  private final Vocabulary vocabulary


  protected final Deque < Pair < ParserRuleContext, Integer >> _parentContextStack =
      new ArrayDeque < Pair < ParserRuleContext, Integer >> ()


  protected int overrideDecision = -1
  protected int overrideDecisionInputIndex = -1
  protected int overrideDecisionAlt = -1
  protected boolean overrideDecisionReached = false # latch and only override once error might trigger infinite loop


  protected InterpreterRuleContext overrideDecisionRoot = null


  protected InterpreterRuleContext rootContext


  @Deprecated
  public ParserInterpreter(String grammarFileName, Collection < String > tokenNames,
                                  Collection < String > ruleNames, ATN atn, TokenStream input)
  this(grammarFileName, VocabularyImpl.fromTokenNames(tokenNames.toArray(new String[tokenNames.size()])), ruleNames, atn, input)
end

public ParserInterpreter(String grammarFileName, Vocabulary vocabulary,
                                                            Collection < String > ruleNames, ATN atn, TokenStream input)

super(input)
this.grammarFileName = grammarFileName
this.atn = atn
this.tokenNames = new String[atn.maxTokenType]
for (int i = 0 i < tokenNames.length
  i + +)
  tokenNames[i] = vocabulary.getDisplayName(i)
end

this.ruleNames = ruleNames.toArray(new String[ruleNames.size()])
this.vocabulary = vocabulary

# init decision DFA
int numberOfDecisions = atn.getNumberOfDecisions()
this.decisionToDFA = new DFA[numberOfDecisions]
for (int i = 0 i < numberOfDecisions
  i + +)
  DecisionState decisionState = atn.getDecisionState(i)
  decisionToDFA[i] = new DFA(decisionState, i)
end

# get atn simulator that knows how to do predictions
setInterpreter(new ParserATNSimulator(this, atn,
                                      decisionToDFA,
                                      sharedContextCache))
end


public void reset()
super.reset()
overrideDecisionReached = false
overrideDecisionRoot = null
end


public ATN getATN()
return atn
end


@Deprecated
public String[] getTokenNames()
return tokenNames
end


public Vocabulary getVocabulary()
return vocabulary
end


public String[] getRuleNames()
return ruleNames
end


public String getGrammarFileName()
return grammarFileName
end


public ParserRuleContext parse(int startRuleIndex)
RuleStartState startRuleStartState = atn.ruleToStartState[startRuleIndex]

rootContext = createInterpreterRuleContext(null, ATNState::INVALID_STATE_NUMBER, startRuleIndex)
if (startRuleStartState.isLeftRecursiveRule)
  enterRecursionRule(rootContext, startRuleStartState.stateNumber, startRuleIndex, 0)
end
else
enterRule(rootContext, startRuleStartState.stateNumber, startRuleIndex)
end

while (true)
  ATNState p = getATNState()
  switch (p.getStateType())
  case ATNState::RULE_STOP :
      # pop return from rule
      if (_ctx.isEmpty())
        if (startRuleStartState.isLeftRecursiveRule)
          ParserRuleContext result = _ctx
          Pair < ParserRuleContext, Integer > parentContext = _parentContextStack.pop()
          unrollRecursionContexts(parentContext.a)
          return result
        end
      else
        exitRule()
        return rootContext
      end
end

visitRuleStopState(p)
break

default :
    try
visitState(p)
end
catch (RecognitionException e)
setState(atn.ruleToStopState[p.ruleIndex].stateNumber)
getContext().exception = e
getErrorHandler().reportError(this, e)
recover(e)
end

break
end
end
end


public void enterRecursionRule(ParserRuleContext localctx, int state, int ruleIndex, int precedence)
Pair < ParserRuleContext, Integer > pair = new Pair < ParserRuleContext, Integer > (_ctx, localctx.invokingState)
_parentContextStack.push(pair)
super.enterRecursionRule(localctx, state, ruleIndex, precedence)
end

protected ATNState getATNState()
return atn.states.get(getState())
end

protected void visitState(ATNState p)
#		System.out.println("visitState "+p.stateNumber)
int predictedAlt = 1
if (p instanceof DecisionState)
  predictedAlt = visitDecisionState((DecisionState) p)
end

Transition transition = p.transition(predictedAlt - 1)
switch (transition.getSerializationType())
case Transition::EPSILON :
    if (p.getStateType() == ATNState::STAR_LOOP_ENTRY &&
        ((StarLoopEntryState) p).isPrecedenceDecision &&
        !(transition.target instanceof LoopEndState))

      # We are at the start of a left recursive rule's (...)* loop
      # and we're not taking the exit branch of loop.
      InterpreterRuleContext localctx =
                                 createInterpreterRuleContext(_parentContextStack.peek().a,
                                                              _parentContextStack.peek().b,
                                                              _ctx.getRuleIndex())
      pushNewRecursionContext(localctx,
                              atn.ruleToStartState[p.ruleIndex].stateNumber,
                              _ctx.getRuleIndex())
    end
break

case Transition::ATOM :
    match(((AtomTransition) transition).label)
break

case Transition::RANGE :
    case Transition::SET :
    case Transition::NOT_SET :
    if (!transition.matches(_input.LA(1), Token::MIN_USER_TOKEN_TYPE, 65535))
      recoverInline()
    end
matchWildcard()
break

case Transition::WILDCARD :
    matchWildcard()
break

case Transition::RULE :
    RuleStartState ruleStartState = (RuleStartState) transition.target
int ruleIndex = ruleStartState.ruleIndex
InterpreterRuleContext newctx = createInterpreterRuleContext(_ctx, p.stateNumber, ruleIndex)
if (ruleStartState.isLeftRecursiveRule)
  enterRecursionRule(newctx, ruleStartState.stateNumber, ruleIndex, ((RuleTransition) transition).precedence)
end
else
enterRule(newctx, transition.target.stateNumber, ruleIndex)
end
break

case Transition::PREDICATE :
    PredicateTransition predicateTransition = (PredicateTransition) transition
if (!sempred(_ctx, predicateTransition.ruleIndex, predicateTransition.predIndex))
  throw new FailedPredicateException(this)
end

break

case Transition::ACTION :
    ActionTransition actionTransition = (ActionTransition) transition
action(_ctx, actionTransition.ruleIndex, actionTransition.actionIndex)
break

case Transition::PRECEDENCE :
    if (!precpred(_ctx, ((PrecedencePredicateTransition) transition).precedence))
      throw new FailedPredicateException(this, String.format("precpred(_ctx, %d)", ((PrecedencePredicateTransition) transition).precedence))
    end
break

default :
    throw new UnsupportedOperationException("Unrecognized ATN transition type.")
end

setState(transition.target.stateNumber)
end


protected int visitDecisionState(DecisionState p)
int predictedAlt = 1
if (p.getNumberOfTransitions() > 1)
  getErrorHandler().sync(this)
  int decision = p.decision
  if (decision == overrideDecision && _input.index() == overrideDecisionInputIndex &&
      !overrideDecisionReached)

    predictedAlt = overrideDecisionAlt
    overrideDecisionReached = true
  end
else
  predictedAlt = @_interp.adaptivePredict(_input, decision, _ctx)
end
end
return predictedAlt
end


protected InterpreterRuleContext createInterpreterRuleContext(
                                     ParserRuleContext parent,
                                                       int invokingStateNumber,
                                                           int ruleIndex)

return new InterpreterRuleContext(parent, invokingStateNumber, ruleIndex)
end

protected void visitRuleStopState(ATNState p)
RuleStartState ruleStartState = atn.ruleToStartState[p.ruleIndex]
if (ruleStartState.isLeftRecursiveRule)
  Pair < ParserRuleContext, Integer > parentContext = _parentContextStack.pop()
  unrollRecursionContexts(parentContext.a)
  setState(parentContext.b)
end
else
exitRule()
end

RuleTransition ruleTransition = (RuleTransition) atn.states.get(getState()).transition(0)
setState(ruleTransition.followState.stateNumber)
end


public void addDecisionOverride(int decision, int tokenIndex, int forcedAlt)
overrideDecision = decision
overrideDecisionInputIndex = tokenIndex
overrideDecisionAlt = forcedAlt
end

public InterpreterRuleContext getOverrideDecisionRoot()
return overrideDecisionRoot
end


protected void recover(RecognitionException e)
int i = _input.index()
getErrorHandler().recover(this, e)
if (_input.index() == i)
  # no input consumed, better add an error node
  if (e instanceof InputMismatchException)
    InputMismatchException ime = (InputMismatchException) e
    Token tok = e.getOffendingToken()
    int expectedTokenType = Token::INVALID_TYPE
    if (!ime.getExpectedTokens().isNil())
      expectedTokenType = ime.getExpectedTokens().getMinElement() # get any element
    end
    Token errToken =
              getTokenFactory().create(new Pair < TokenSource, CharStream > (tok.getTokenSource(), tok.getTokenSource().getInputStream()),
                                           expectedTokenType, tok.getText(),
                                           Token::DEFAULT_CHANNEL,
                                           -1, -1, # invalid start/stop
                                           tok.getLine(), tok.getCharPositionInLine())
    _ctx.addErrorNode(createErrorNode(_ctx, errToken))
  end
else # NoViableAlt
  Token tok = e.getOffendingToken()
  Token errToken =
            getTokenFactory().create(new Pair < TokenSource, CharStream > (tok.getTokenSource(), tok.getTokenSource().getInputStream()),
                                         Token::INVALID_TYPE, tok.getText(),
                                         Token::DEFAULT_CHANNEL,
                                         -1, -1, # invalid start/stop
                                         tok.getLine(), tok.getCharPositionInLine())
  _ctx.addErrorNode(createErrorNode(_ctx, errToken))
end
end
end

protected Token recoverInline()
return _errHandler.recoverInline(this)
end


public InterpreterRuleContext getRootContext()
return rootContext
end
end

