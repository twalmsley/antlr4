class ParserATNSimulator
  extends ATNSimulator
  public static final boolean debug = false
  public static final boolean debug_list_atn_decisions = false
  public static final boolean dfa_debug = false
  public static final boolean retry_debug = false


  public static final boolean TURN_OFF_LR_LOOP_ENTRY_BRANCH_OPT = Boolean.parseBoolean(getSafeEnv("TURN_OFF_LR_LOOP_ENTRY_BRANCH_OPT"))

  protected final Parser parser

  public final DFA[] decisionToDFA


  private PredictionMode mode = PredictionMode.LL


  protected DoubleKeyMap < PredictionContext, PredictionContext, PredictionContext > mergeCache

  # LAME globals to avoid parameters!!!!! I need these down deep in predTransition
  protected TokenStream _input
  protected int _startIndex
  protected ParserRuleContext _outerContext
  protected DFA _dfa


  public ParserATNSimulator(ATN atn, DFA[] decisionToDFA,
      PredictionContextCache sharedContextCache)

  this(null, atn, decisionToDFA, sharedContextCache)
end

public ParserATNSimulator(Parser parser, ATN atn,
                                             DFA[] decisionToDFA,
    PredictionContextCache sharedContextCache)

super(atn, sharedContextCache)
this.parser = parser
this.decisionToDFA = decisionToDFA
#		DOTGenerator dot = new DOTGenerator(null)
#		System.out.println(dot.getDOT(atn.rules.get(0), parser.getRuleNames()))
#		System.out.println(dot.getDOT(atn.rules.get(1), parser.getRuleNames()))
end


public void reset()
end


public void clearDFA()
for (int d = 0
  d < decisionToDFA.length d + +)
  decisionToDFA[d] = new DFA(atn.getDecisionState(d), d)
end
end

public int adaptivePredict(TokenStream input, int decision,
                                                  ParserRuleContext outerContext)

if (debug || debug_list_atn_decisions)
  System.out.println("adaptivePredict decision " + decision +
                         " exec LA(1)==" + getLookaheadName(input) +
                         " line " + input.LT(1).getLine() + ":" + input.LT(1).getCharPositionInLine())
end

_input = input
_startIndex = input.index()
_outerContext = outerContext
DFA dfa = decisionToDFA[decision]
_dfa = dfa

int m = input.mark()
int index = _startIndex

# Now we are certain to have a specific decision's DFA
# But, do we still need an initial state?
try
DFAState s0
if (dfa.isPrecedenceDfa())
  # the start state for a precedence DFA depends on the current
  # parser precedence, and is provided by a DFA method.
  s0 = dfa.getPrecedenceStartState(parser.getPrecedence())
end
else
# the start state for a "regular" DFA is just s0
s0 = dfa.s0
end

if (s0 == null)
  if (outerContext == null)
    outerContext = ParserRuleContext.EMPTY
    if (debug || debug_list_atn_decisions)
      System.out.println("predictATN decision " + dfa.decision +
                             " exec LA(1)==" + getLookaheadName(input) +
                             ", outerContext=" + outerContext.to_s(parser))
    end

    boolean fullCtx = false
    ATNConfigSet s0_closure =
                     computeStartState(dfa.atnStartState,
                                       ParserRuleContext.EMPTY,
                                       fullCtx)

    if (dfa.isPrecedenceDfa())


      dfa.s0.configs = s0_closure # not used for prediction but useful to know start configs anyway
      s0_closure = applyPrecedenceFilter(s0_closure)
      s0 = addDFAState(dfa, new DFAState(s0_closure))
      dfa.setPrecedenceStartState(parser.getPrecedence(), s0)
    end
  else
    s0 = addDFAState(dfa, new DFAState(s0_closure))
    dfa.s0 = s0
  end
end

int alt = execATN(dfa, s0, input, index, outerContext)
if (debug)
  System.out.println("DFA after predictATN: " + dfa.to_s(parser.getVocabulary()))
  return alt
end
finally
mergeCache = null # wack cache after each prediction
_dfa = null
input.seek(index)
input.release(m)
end
end


There are some key conditions we 're looking for after computing a new
	 set of ATN configs (proposed DFA state):



	         putting it on the work list?

	 We also have some key operations to do:

	         upon current symbol but only if adding to work list, which means in all
	         cases except no viable alternative (and possibly non-greedy decisions?)








	 cover these cases:
	    dead end
	    single alt
	    single alt + preds
	    conflict
	    conflict + preds

	protected int execATN(DFA dfa, DFAState s0,
					   TokenStream input, int startIndex,
					   ParserRuleContext outerContext)
	
		if ( debug || debug_list_atn_decisions) 
			System.out.println("execATN decision "+dfa.decision+
							   " exec LA(1)=="+ getLookaheadName(input)+
							   " line "+input.LT(1).getLine()+":"+input.LT(1).getCharPositionInLine())
		end

		DFAState previousD = s0

		if ( debug ) System.out.println("s0 = "+s0)

		int t = input.LA(1)

		while (true)  # while more work
			DFAState D = getExistingTargetState(previousD, t)
			if (D == null) 
				D = computeTargetState(dfa, previousD, t)
			end

			if (D == ERROR) 
				# if any configs in previous dipped into outer context, that
				# means that input up to t actually finished entry rule
				# at least for SLL decision. Full LL doesn' t dip into outer
# so don't need special case.
# We will get an error no matter what so delay until after
# decision better error message. Also, no reachable target
# ATN states in SLL implies LL will also get nowhere.
# If conflict in states that dip out, choose min since we
# will get error no matter what.
NoViableAltException e = noViableAlt(input, outerContext, previousD.configs, startIndex)
input.seek(startIndex)
int alt = getSynValidOrSemInvalidAltThatFinishedDecisionEntryRule(previousD.configs, outerContext)
if (alt != ATN.INVALID_ALT_NUMBER)
  return alt
end
throw e
end

if (D.requiresFullContext && mode != PredictionMode.SLL)
  # IF PREDS, MIGHT RESOLVE TO SINGLE ALT => SLL (or syntax error)
  BitSet conflictingAlts = D.configs.conflictingAlts
  if (D.predicates != null)
    if (debug)
      System.out.println("DFA state has preds in DFA sim LL failover")
      int conflictIndex = input.index()
      if (conflictIndex != startIndex)
        input.seek(startIndex)
      end

      conflictingAlts = evalSemanticContext(D.predicates, outerContext, true)
      if (conflictingAlts.cardinality() == 1)
        if (debug)
          System.out.println("Full LL avoided")
          return conflictingAlts.nextSetBit(0)
        end

        if (conflictIndex != startIndex)
          # restore the index so reporting the fallback to full
          # context occurs with the index at the correct spot
          input.seek(conflictIndex)
        end
      end

      if (dfa_debug)
        System.out.println("ctx sensitive state " + outerContext + " in " + D)
        boolean fullCtx = true
        ATNConfigSet s0_closure =
                         computeStartState(dfa.atnStartState, outerContext,
                                           fullCtx)
        reportAttemptingFullContext(dfa, conflictingAlts, D.configs, startIndex, input.index())
        int alt = execATNWithFullContext(dfa, D, s0_closure,
                                         input, startIndex,
                                         outerContext)
        return alt
      end

      if (D.isAcceptState)
        if (D.predicates == null)
          return D.prediction
        end

        int stopIndex = input.index()
        input.seek(startIndex)
        BitSet alts = evalSemanticContext(D.predicates, outerContext, true)
        switch (alts.cardinality())
        case 0 :
            throw noViableAlt(input, outerContext, D.configs, startIndex)

        case 1 :
            return alts.nextSetBit(0)

        default :
            # report ambiguity after predicate evaluation to make sure the correct
            # set of ambig alts is reported.
            reportAmbiguity(dfa, D, startIndex, stopIndex, false, alts, D.configs)
        return alts.nextSetBit(0)
      end
    end

    previousD = D

    if (t != IntStream.EOF)
      input.consume()
      t = input.LA(1)
    end
  end
end


protected DFAState getExistingTargetState(DFAState previousD, int t)
DFAState[] edges = previousD.edges
if (edges == null || t + 1 < 0 || t + 1 >= edges.length)
  return null
end

return edges[t + 1]
end


protected DFAState computeTargetState(DFA dfa, DFAState previousD, int t)
ATNConfigSet reach = computeReachSet(previousD.configs, t, false)
if (reach == null)
  addDFAEdge(dfa, previousD, t, ERROR)
  return ERROR
end

# create new target state we'll add to DFA after it's complete
DFAState D = new DFAState(reach)

int predictedAlt = getUniqueAlt(reach)

if (debug)
  Collection < BitSet > altSubSets = PredictionMode.getConflictingAltSubsets(reach)
  System.out.println("SLL altSubSets=" + altSubSets +
                         ", configs=" + reach +
                         ", predict=" + predictedAlt + ", allSubsetsConflict=" +
                         PredictionMode.allSubsetsConflict(altSubSets) + ", conflictingAlts=" +
                         getConflictingAlts(reach))
end

if (predictedAlt != ATN.INVALID_ALT_NUMBER)
  # NO CONFLICT, UNIQUELY PREDICTED ALT
  D.isAcceptState = true
  D.configs.uniqueAlt = predictedAlt
  D.prediction = predictedAlt
end
else
if (PredictionMode.hasSLLConflictTerminatingPrediction(mode, reach))
  # MORE THAN ONE VIABLE ALTERNATIVE
  D.configs.conflictingAlts = getConflictingAlts(reach)
  D.requiresFullContext = true
  # in SLL-only mode, we will stop at this state and return the minimum alt
  D.isAcceptState = true
  D.prediction = D.configs.conflictingAlts.nextSetBit(0)
end

if (D.isAcceptState && D.configs.hasSemanticContext)
  predicateDFAState(D, atn.getDecisionState(dfa.decision))
  if (D.predicates != null)
    D.prediction = ATN.INVALID_ALT_NUMBER
  end
end

# all adds to dfa are done after we've created full D state
D = addDFAEdge(dfa, previousD, t, D)
return D
end

protected void predicateDFAState(DFAState dfaState, DecisionState decisionState)
# We need to test all predicates, even in DFA states that
# uniquely predict alternative.
int nalts = decisionState.getNumberOfTransitions()
# Update DFA so reach becomes accept state with (predicate,alt)
# pairs if preds found for conflicting alts
BitSet altsToCollectPredsFrom = getConflictingAltsOrUniqueAlt(dfaState.configs)
SemanticContext[] altToPred = getPredsForAmbigAlts(altsToCollectPredsFrom, dfaState.configs, nalts)
if (altToPred != null)
  dfaState.predicates = getPredicatePredictions(altsToCollectPredsFrom, altToPred)
  dfaState.prediction = ATN.INVALID_ALT_NUMBER # make sure we use preds
end
else
# There are preds in configs but they might go away
# when OR'd together like pend? || NONE == NONE. If neither
# alt has preds, resolve to min alt
dfaState.prediction = altsToCollectPredsFrom.nextSetBit(0)
end
end

# comes back with reach.uniqueAlt set to a valid alt
protected int execATNWithFullContext(DFA dfa,
                                         DFAState D, # how far we got in SLL DFA before failing over
                                                  ATNConfigSet s0,
                                                               TokenStream input, int startIndex,
                                                                                      ParserRuleContext outerContext)

if (debug || debug_list_atn_decisions)
  System.out.println("execATNWithFullContext " + s0)
end
boolean fullCtx = true
boolean foundExactAmbig = false
ATNConfigSet reach = null
ATNConfigSet previous = s0
input.seek(startIndex)
int t = input.LA(1)
int predictedAlt
while (true) # while more work
#			System.out.println("LL REACH "+getLookaheadName(input)+
#							   " from configs.size="+previous.size()+
#							   " line "+input.LT(1).getLine()+":"+input.LT(1).getCharPositionInLine())
  reach = computeReachSet(previous, t, fullCtx)
  if (reach == null)
    # if any configs in previous dipped into outer context, that
    # means that input up to t actually finished entry rule
    # at least for LL decision. Full LL doesn't dip into outer
    # so don't need special case.
    # We will get an error no matter what so delay until after
    # decision better error message. Also, no reachable target
    # ATN states in SLL implies LL will also get nowhere.
    # If conflict in states that dip out, choose min since we
    # will get error no matter what.
    NoViableAltException e = noViableAlt(input, outerContext, previous, startIndex)
    input.seek(startIndex)
    int alt = getSynValidOrSemInvalidAltThatFinishedDecisionEntryRule(previous, outerContext)
    if (alt != ATN.INVALID_ALT_NUMBER)
      return alt
    end
    throw e
  end

  Collection < BitSet > altSubSets = PredictionMode.getConflictingAltSubsets(reach)
  if (debug)
    System.out.println("LL altSubSets=" + altSubSets +
                           ", predict=" + PredictionMode.getUniqueAlt(altSubSets) +
                           ", resolvesToJustOneViableAlt=" +
                           PredictionMode.resolvesToJustOneViableAlt(altSubSets))
  end

#			System.out.println("altSubSets: "+altSubSets)
#			System.err.println("reach="+reach+", "+reach.conflictingAlts)
  reach.uniqueAlt = getUniqueAlt(reach)
# unique prediction?
  if (reach.uniqueAlt != ATN.INVALID_ALT_NUMBER)
    predictedAlt = reach.uniqueAlt
    break
  end
  if (mode != PredictionMode.LL_EXACT_AMBIG_DETECTION)
    predictedAlt = PredictionMode.resolvesToJustOneViableAlt(altSubSets)
    if (predictedAlt != ATN.INVALID_ALT_NUMBER)
      break
    end
  end
  else
# In exact ambiguity mode, we never try to terminate early.
# Just keeps scarfing until we know what the conflict is
  if (PredictionMode.allSubsetsConflict(altSubSets) &&
      PredictionMode.allSubsetsEqual(altSubSets))

    foundExactAmbig = true
    predictedAlt = PredictionMode.getSingleViableAlt(altSubSets)
    break
  end
# else there are multiple non-conflicting subsets or
# we're not sure what the ambiguity is yet.
# So, keep going.
end

previous = reach
if (t != IntStream.EOF)
  input.consume()
  t = input.LA(1)
end
end

# If the configuration set uniquely predicts an alternative,
# without conflict, then we know that it's a full LL decision
# not SLL.
if (reach.uniqueAlt != ATN.INVALID_ALT_NUMBER)
  reportContextSensitivity(dfa, predictedAlt, reach, startIndex, input.index())
  return predictedAlt
end

# We do not check predicates here because we have checked them
# on-the-fly when doing full context prediction.


In non - exact ambiguity detection mode, we might actually be able to
detect an exact ambiguity, but I 'm not going to spend the cycles
		needed to check. We only emit ambiguity warnings in exact ambiguity
		mode.

		For example, we might know that we have conflicting configurations.
		But, that does not mean that there is no way forward without a
		conflict. It' s possible to have nonconflicting alt subsets as in:

                                                                                                             LL altSubSets = [1, 2 end, 1, 2 end, 1 end, 1, 2 end]

from

[(17, 1, [5 $]), (13, 1, [5 10 $]), (21, 1, [5 10 $]), (11, 1, [ $]),
 (13, 2, [5 10 $]), (21, 2, [5 10 $]), (11, 2, [ $])]

In this case, (17, 1, [5 $]) indicates there is some next sequence that
would resolve this without conflict to alternative 1.Any other viable
next sequence, however, is associated with a conflict.We stop
looking for input because no amount of further lookahead will alter
          the fact that we should predict alternative 1.We just can 't say for
		sure that there is an ambiguity without looking further.

		reportAmbiguity(dfa, D, startIndex, input.index(), foundExactAmbig,
						reach.getAlts(), reach)

		return predictedAlt
	end

	protected ATNConfigSet computeReachSet(ATNConfigSet closure, int t,
										   boolean fullCtx)
	
		if ( debug )
			System.out.println("in computeReachSet, starting closure: " + closure)

		if (mergeCache == null) 
			mergeCache = new DoubleKeyMap<PredictionContext, PredictionContext, PredictionContext>()
		end

		ATNConfigSet intermediate = new ATNConfigSet(fullCtx)











		List<ATNConfig> skippedStopStates = null

		# First figure out where we can reach on input t
		for (ATNConfig c : closure) 
			if ( debug ) System.out.println("testing "+getTokenName(t)+" at "+c.to_s())

			if (c.state instanceof RuleStopState) 
				assert c.context.isEmpty()
				if (fullCtx || t == IntStream.EOF) 
					if (skippedStopStates == null) 
						skippedStopStates = new ArrayList<ATNConfig>()
					end

					skippedStopStates.add(c)
				end

				continue
			end

			int n = c.state.getNumberOfTransitions()
			for (int ti=0 ti<n ti++)                # for each transition
				Transition trans = c.state.transition(ti)
				ATNState target = getReachableTarget(trans, t)
				if ( target!=null ) 
					intermediate.add(new ATNConfig(c, target), mergeCache)
				end
			end
		end

		# Now figure out where the reach operation can take us...

		ATNConfigSet reach = null










		if (skippedStopStates == null && t != Token.EOF) 
			if ( intermediate.size()==1 ) 
				# Don' t pursue the closure if there is just one state.
              # It can only have one alternative just add to result
              # Also don't pursue the closure if there is unique alternative
              # among the configurations.
              reach = intermediate
        end
else
if (getUniqueAlt(intermediate) != ATN.INVALID_ALT_NUMBER)
  # Also don't pursue the closure if there is unique alternative
  # among the configurations.
  reach = intermediate
end
end


if (reach == null)
  reach = new ATNConfigSet(fullCtx)
  Set < ATNConfig > closureBusy = new HashSet < ATNConfig > ()
  boolean treatEofAsEpsilon = t == Token.EOF
  for (ATNConfig c :
    intermediate)
    closure(c, reach, closureBusy, false, fullCtx, treatEofAsEpsilon)
  end
end

if (t == IntStream.EOF)


  reach = removeAllConfigsNotInRuleStopState(reach, reach == intermediate)
end


if (skippedStopStates != null && (!fullCtx || !PredictionMode.hasConfigInRuleStopState(reach)))
  assert !skippedStopStates.isEmpty()
  for (ATNConfig c :
    skippedStopStates)
    reach.add(c, mergeCache)
  end
end

if (reach.isEmpty())
  return null
  return reach
end


protected ATNConfigSet removeAllConfigsNotInRuleStopState(ATNConfigSet configs, boolean lookToEndOfRule)
if (PredictionMode.allConfigsInRuleStopStates(configs))
  return configs
end

ATNConfigSet result = new ATNConfigSet(configs.fullCtx)
for (ATNConfig config :
  configs)
  if (config.state instanceof RuleStopState)
    result.add(config, mergeCache)
    continue
  end

  if (lookToEndOfRule && config.state.onlyHasEpsilonTransitions())
    IntervalSet nextTokens = atn.nextTokens(config.state)
    if (nextTokens.contains(Token.EPSILON))
      ATNState endOfRuleState = atn.ruleToStopState[config.state.ruleIndex]
      result.add(new ATNConfig(config, endOfRuleState), mergeCache)
    end
  end
end

return result
end


protected ATNConfigSet computeStartState(ATNState p,
                                                  RuleContext ctx,
                                                              boolean fullCtx)

# always at least the implicit call to start rule
PredictionContext initialContext = PredictionContext.fromRuleContext(atn, ctx)
ATNConfigSet configs = new ATNConfigSet(fullCtx)

for (int i = 0 i < p.getNumberOfTransitions()
  i + +)
  ATNState target = p.transition(i).target
  ATNConfig c = new ATNConfig(target, i + 1, initialContext)
  Set < ATNConfig > closureBusy = new HashSet < ATNConfig > ()
  closure(c, configs, closureBusy, true, fullCtx, false)
end

return configs
end


context - sensitive in that they can only be properly evaluated
in the context of the proper prec argument.Without pruning,
                                                   these predicates are normal predicates evaluated when we reach
conflict state (or unique prediction).As we cannot evaluate
these predicates out of context, the resulting conflict leads
to full LL evaluation and nonlinear prediction which shows up
very clearly with fairly large expressions.

    Example grammar:

                e : e '*' e
| e '+' e
| INT


We convert that to the following:

                           e[int prec]
: INT
(3 >= precend? '*' e[4]
| 2 >= precend? '+' e[3]
) *


    The (..) * loop has a decision for the inner block as well as
                                     an enter or exit decision, which is what concerns us here.At
                                     the 1 st + of input 1 + 2 + 3, the loop entry sees both predicates
                                     and the loop exit also sees both predicates by falling off the
                                     edge of e.This is because we have no stack information with
                                     SLL and find the follow of e, which will hit the return states
                                     inside the loop after e[4] and e[3], which brings it back to
                                     the enter or exit decision.In this case, we know that we
                                     cannot evaluate those predicates because we have fallen off
                                     the edge of the stack and will in general not know which prec
                                     parameter is the right one to use in the predicate.

                                         Because we have special information, that these are precedence
                                     predicates, we can resolve them without failing over to full
                                     LL despite their context sensitive nature.We make an
                                     assumption that prec[-1] <= prec[0], meaning that the current
                                     precedence level is greater than or equal to the precedence
                                     level of recursive invocations above us in the stack.For
                                     example, if predicate 3 >= precend?
                                                is true of the current prec,
                                                then one option is to enter the loop to match it now.The
                                                other option is to exit the loop and the left recursive rule
                                                to match the current operator in rule invocation further up
                                                the stack.But, we know that all of those prec are lower or
                                                    the same value and so we can decide to enter the loop instead
                                                of matching it later.That means we can strip out the other
                                                configuration for the exit branch.

                                                    So imagine we have (14, 1, $,
                                                                2 >= precend?) and then
                                                                (14, 2, $-d ipsIntoOuterContext, 2 >= precend?).The optimization
                                                                allows us to collapse these two configurations.We know that
                                                                if 2 >= precend?
                                                                  is true
                                                                  for the current prec parameter, it will
                                                                    also be true
                                                                    for any prec from an invoking e call, indicated
                                                                      by dipsIntoOuterContext.As the predicates are both true, we
                                                                      have the option to evaluate them early in the decision start
                                                                      state.We do
                                                                        this by stripping both predicates and choosing to
                                                                        enter the loop as it is consistent with the notion of operator
                                                                        precedence.It 's also how the full LL conflict resolution
		would work.

		The solution requires a different DFA start state for each
		precedence level.

		The basic filter mechanism is to remove configurations of the
		form (p, 2, pi) if (p, 1, pi) exists for the same p and pi. In
		other words, for the same ATN state and predicate context,
		remove any configuration associated with an exit branch if
		there is a configuration associated with the enter branch.

		It' s also the case that the filter evaluates precedence
                                                                        predicates and resolves conflicts according to precedence
                                                                        levels.For example, for input 1 + 2 + 3
                                                                                              at the first +, we see
                                                                                              prediction filtering

                                                                                              [(11, 1, [ $], 3 >= precend?), (14, 1, [ $], 2 >= precend?), (5, 2, [ $], up = 1),
                                                                                               (11, 2, [ $], up = 1), (14, 2, [ $], up = 1)], hasSemanticContext = true, dipsIntoOuterContext

                                                                                              to

                                                                                              [(11, 1, [ $]), (14, 1, [ $]), (5, 2, [ $], up = 1)], dipsIntoOuterContext

                                                                                              This filters because 3 >= precend? evals to true and collapses
                                                                                              (11, 1, [ $], 3 >= precend?) and (11, 2, [ $], up = 1) since early conflict
                                                                                              resolution based upon rules of operator precedence fits with
                                                                                              our usual match first alt upon conflict.

                                                                                                  We noticed a problem where a recursive call resets precedence
                                                                                              to 0.Sam 's fix: each config has flag indicating if it has
		returned from an expr[0] call. then just don' t filter any
                                                                                              config with that flag set.flag is carried along in
                                                                                              closure().so to avoid adding field, set bit just under sign
                                                                                              bit of dipsIntoOuterContext (SUPPRESS_PRECEDENCE_FILTER).
                                                                                                  With the change you filter "unless (p, 2, pi) was reached
		after leaving the rule stop state of the LR rule containing
		state p, corresponding to a rule invocation with precedence
		level 0"


                                                                                              protected ATNConfigSet applyPrecedenceFilter(ATNConfigSet configs)
                                                                                              Map < Integer, PredictionContext > statesFromAlt1 = new HashMap < Integer, PredictionContext > ()
                                                                                              ATNConfigSet configSet = new ATNConfigSet(configs.fullCtx)
                                                                                              for (ATNConfig config :
                                                                                                configs)
                                                                                                # handle alt 1 first
                                                                                                if (config.alt != 1)
                                                                                                  continue
                                                                                                end

                                                                                                SemanticContext updatedContext = config.semanticContext.evalPrecedence(parser, _outerContext)
                                                                                                if (updatedContext == null)
                                                                                                  # the configuration was eliminated
                                                                                                  continue
                                                                                                end

                                                                                                statesFromAlt1.put(config.state.stateNumber, config.context)
                                                                                                if (updatedContext != config.semanticContext)
                                                                                                  configSet.add(new ATNConfig(config, updatedContext), mergeCache)
                                                                                                end
                                                                                                else
                                                                                                configSet.add(config, mergeCache)
                                                                                              end
                                                                        end

                                                                        for (ATNConfig config :
                                                                          configs)
                                                                          if (config.alt == 1)
                                                                            # already handled
                                                                            continue
                                                                          end

                                                                          if (!config.isPrecedenceFilterSuppressed())


                                                                            PredictionContext context = statesFromAlt1.get(config.state.stateNumber)
                                                                            if (context != null && context.equals(config.context))
                                                                              # eliminated
                                                                              continue
                                                                            end
                                                                          end

                                                                          configSet.add(config, mergeCache)
                                                                        end

                                                                        return configSet
                                                                      end

                                                                      protected ATNState getReachableTarget(Transition trans, int ttype)
                                                                      if (trans.matches(ttype, 0, atn.maxTokenType))
                                                                        return trans.target
                                                                      end

                                                                      return null
                                                                      end

                                                                      protected SemanticContext[] getPredsForAmbigAlts(BitSet ambigAlts,
                                                                                                                              ATNConfigSet configs,
                                                                                                                                           int nalts)

                                                                      # REACH=[1|1|[]|0:0, 1|2|[]|0:1]


                                                                      SemanticContext[] altToPred = new SemanticContext[nalts + 1]
                                                                      for (ATNConfig c :
                                                                        configs)
                                                                        if (ambigAlts.get(c.alt))
                                                                          altToPred[c.alt] = SemanticContext.or(altToPred[c.alt], c.semanticContext)
                                                                        end
                                                                      end

                                                                      int nPredAlts = 0
                                                                      for (int i = 1 i <= nalts
                                                                        i + +)
                                                                        if (altToPred[i] == null)
                                                                          altToPred[i] = SemanticContext.NONE
                                                                        end
                                                                        else
                                                                        if (altToPred[i] != SemanticContext.NONE)
                                                                          nPredAlts + +
                                                                        end
                                                                      end

                                                                      #		# Optimize away p||p and p&&p TODO: optimize() was a no-op
                                                                      #		for (int i = 0 i < altToPred.length i++)
                                                                      #			altToPred[i] = altToPred[i].optimize()
                                                                      #		end

                                                                      # nonambig alts are null in altToPred
                                                                      if (nPredAlts == 0)
                                                                        altToPred = null
                                                                        if (debug)
                                                                          System.out.println("getPredsForAmbigAlts result " + Arrays.to_s(altToPred))
                                                                          return altToPred
                                                                        end

                                                                        protected DFAState.PredPrediction[] getPredicatePredictions(BitSet ambigAlts,
                                                                                                                                           SemanticContext[] altToPred)

                                                                        List < DFAState.PredPrediction > pairs = new ArrayList < DFAState.PredPrediction > ()
                                                                        boolean containsPredicate = false
                                                                        for (int i = 1 i < altToPred.length
                                                                          i + +)
                                                                          SemanticContext pred = altToPred[i]

                                                                          # unpredicated is indicated by SemanticContext.NONE
                                                                          assert pred != null

                                                                          if (ambigAlts != null && ambigAlts.get(i))
                                                                            pairs.add(new DFAState.PredPrediction(pred, i))
                                                                          end
                                                                          if (pred != SemanticContext.NONE)
                                                                            containsPredicate = true
                                                                          end

                                                                          if (!containsPredicate)
                                                                            return null
                                                                          end

                                                                          #		System.out.println(Arrays.to_s(altToPred)+"->"+pairs)
                                                                          return pairs.toArray(new DFAState.PredPrediction[pairs.size()])
                                                                        end


                                                                        protected int getSynValidOrSemInvalidAltThatFinishedDecisionEntryRule(ATNConfigSet configs,
                                                                                                                                                           ParserRuleContext outerContext)

                                                                        Pair < ATNConfigSet, ATNConfigSet > sets =
                                                                            splitAccordingToSemanticValidity(configs, outerContext)
                                                                        ATNConfigSet semValidConfigs = sets.a
                                                                        ATNConfigSet semInvalidConfigs = sets.b
                                                                        int alt = getAltThatFinishedDecisionEntryRule(semValidConfigs)
                                                                        if (alt != ATN.INVALID_ALT_NUMBER) # semantically/syntactically viable path exists
                                                                          return alt
                                                                        end
                                                                        # Is there a syntactically valid path with a failed pred?
                                                                        if (semInvalidConfigs.size() > 0)
                                                                          alt = getAltThatFinishedDecisionEntryRule(semInvalidConfigs)
                                                                          if (alt != ATN.INVALID_ALT_NUMBER) # syntactically viable path exists
                                                                            return alt
                                                                          end
                                                                        end
                                                                        return ATN.INVALID_ALT_NUMBER
                                                                      end

                                                                      protected int getAltThatFinishedDecisionEntryRule(ATNConfigSet configs)
                                                                      IntervalSet alts = new IntervalSet()
                                                                      for (ATNConfig c :
                                                                        configs)
                                                                        if (c.getOuterContextDepth() > 0 || (c.state instanceof RuleStopState && c.context.hasEmptyPath()))
                                                                          alts.add(c.alt)
                                                                        end
                                                                      end
                                                                      if (alts.size() == 0)
                                                                        return ATN.INVALID_ALT_NUMBER
                                                                        return alts.getMinElement()
                                                                      end


                                                                      protected Pair < ATNConfigSet, ATNConfigSet > splitAccordingToSemanticValidity(
                                                                          ATNConfigSet configs,
                                                                                       ParserRuleContext outerContext)

                                                                      ATNConfigSet succeeded = new ATNConfigSet(configs.fullCtx)
                                                                      ATNConfigSet failed = new ATNConfigSet(configs.fullCtx)
                                                                      for (ATNConfig c :
                                                                        configs)
                                                                        if (c.semanticContext != SemanticContext.NONE)
                                                                          boolean predicateEvaluationResult = evalSemanticContext(c.semanticContext, outerContext, c.alt, configs.fullCtx)
                                                                          if (predicateEvaluationResult)
                                                                            succeeded.add(c)
                                                                          end
                                                                        else
                                                                          failed.add(c)
                                                                        end
                                                                      end
                                                                      else
                                                                      succeeded.add(c)
                                                                    end
                                                                  end
                                                                  return new Pair < ATNConfigSet, ATNConfigSet > (succeeded, failed)
                                                                end


                                                                protected BitSet evalSemanticContext(DFAState.PredPrediction[] predPredictions,
                                                                    ParserRuleContext outerContext,
                                                                    boolean complete)

                                                                BitSet predictions = new BitSet()
                                                                for (DFAState.PredPrediction pair :
                                                                  predPredictions)
                                                                  if (pair.pred == SemanticContext.NONE)
                                                                    predictions.set(pair.alt)
                                                                    if (!complete)
                                                                      break
                                                                    end
                                                                    continue
                                                                  end

                                                                  boolean fullCtx = false # in dfa
                                                                  boolean predicateEvaluationResult = evalSemanticContext(pair.pred, outerContext, pair.alt, fullCtx)
                                                                  if (debug || dfa_debug)
                                                                    System.out.println("eval pred " + pair + "=" + predicateEvaluationResult)
                                                                  end

                                                                  if (predicateEvaluationResult)
                                                                    if (debug || dfa_debug)
                                                                      System.out.println("PREDICT " + pair.alt)
                                                                      predictions.set(pair.alt)
                                                                      if (!complete)
                                                                        break
                                                                      end
                                                                    end
                                                                  end

                                                                  return predictions
                                                                end


                                                                protected boolean evalSemanticContext(SemanticContext pred, ParserRuleContext parserCallStack, int alt, boolean fullCtx)
                                                                return pred.eval(parser, parserCallStack)
                                                              end


                                                closure operations if we reach a DFA state that uniquely predicts
                                                alternative.We will not be caching that DFA state and it is a
                                                waste to pursue the closure.Might have to advance when we do
                                                  ambig detection thought : (


                                                  protected void closure(ATNConfig config,
                                                                                   ATNConfigSet configs,
                                                                                                Set < ATNConfig > closureBusy,
                                                                                                boolean collectPredicates,
                                                                                                        boolean fullCtx,
                                                                                                                boolean treatEofAsEpsilon)

                                                  final int initialDepth = 0
                                                  closureCheckingStopState(config, configs, closureBusy, collectPredicates,
                                                                           fullCtx,
                                                                           initialDepth, treatEofAsEpsilon)
                                                  assert !fullCtx || !configs.dipsIntoOuterContext
                                                end

                                                protected void closureCheckingStopState(ATNConfig config,
                                                                                                  ATNConfigSet configs,
                                                                                                               Set < ATNConfig > closureBusy,
                                                                                                               boolean collectPredicates,
                                                                                                                       boolean fullCtx,
                                                                                                                               int depth,
                                                                                                                                   boolean treatEofAsEpsilon)

                                                if (debug)
                                                  System.out.println("closure(" + config.to_s(parser, true) + ")")

                                                  if (config.state instanceof RuleStopState)
                                                    # We hit rule end. If we have context info, use it
                                                    # run thru all possible stack tops in ctx
                                                    if (!config.context.isEmpty())
                                                      for (int i = 0 i < config.context.size()
                                                        i + +)
                                                        if (config.context.getReturnState(i) == PredictionContext.EMPTY_RETURN_STATE)
                                                          if (fullCtx)
                                                            configs.add(new ATNConfig(config, config.state, PredictionContext.EMPTY), mergeCache)
                                                            continue
                                                          end
                                                        else
                                                          # we have no context info, just chase follow links (if greedy)
                                                          if (debug)
                                                            System.out.println("FALLING off rule " +
                                                                                   getRuleName(config.state.ruleIndex))
                                                            closure_(config, configs, closureBusy, collectPredicates,
                                                                     fullCtx, depth, treatEofAsEpsilon)
                                                          end
                                                          continue
                                                        end
                                                        ATNState returnState = atn.states.get(config.context.getReturnState(i))
                                                        PredictionContext newContext = config.context.getParent(i) # "pop" return state
                                                        ATNConfig c = new ATNConfig(returnState, config.alt, newContext,
                                                                                    config.semanticContext)
                                                        # While we have context to pop back from, we may have
                                                        # gotten that context AFTER having falling off a rule.
                                                        # Make sure we track that we are now out of context.
                                                        #
                                                        # This assignment also propagates the
                                                        # isPrecedenceFilterSuppressed() value to the new
                                                        # configuration.
                                                        c.reachesIntoOuterContext = config.reachesIntoOuterContext
                                                        assert depth > Integer.MIN_VALUE
                                                        closureCheckingStopState(c, configs, closureBusy, collectPredicates,
                                                                                 fullCtx, depth - 1, treatEofAsEpsilon)
                                                      end
                                                      return
                                                    end
                                                  else
                                                    if (fullCtx)
                                                      # reached end of start rule
                                                      configs.add(config, mergeCache)
                                                      return
                                                    end
                                                    else
                                                    # else if we have no context info, just chase follow links (if greedy)
                                                    if (debug)
                                                      System.out.println("FALLING off rule " +
                                                                             getRuleName(config.state.ruleIndex))
                                                    end
                                                  end

                                                  closure_(config, configs, closureBusy, collectPredicates,
                                                           fullCtx, depth, treatEofAsEpsilon)
                                                end


                                                protected void closure_(ATNConfig config,
                                                                                  ATNConfigSet configs,
                                                                                               Set < ATNConfig > closureBusy,
                                                                                               boolean collectPredicates,
                                                                                                       boolean fullCtx,
                                                                                                               int depth,
                                                                                                                   boolean treatEofAsEpsilon)

                                                ATNState p = config.state
                                                # optimization
                                                if (!p.onlyHasEpsilonTransitions())
                                                  configs.add(config, mergeCache)
                                                  # make sure to not return here, because EOF transitions can act as
                                                  # both epsilon transitions and non-epsilon transitions.
                                                  #            if ( debug ) System.out.println("added config "+configs)
                                                end

                                                for (int i = 0 i < p.getNumberOfTransitions()
                                                  i + +)
                                                  if (i == 0 && canDropLoopEntryEdgeInLeftRecursiveRule(config))
                                                    continue

                                                    Transition t = p.transition(i)
                                                    boolean continueCollecting =
                                                                !(t instanceof ActionTransition) && collectPredicates
                                                    ATNConfig c = getEpsilonTarget(config, t, continueCollecting,
                                                                                   depth == 0, fullCtx, treatEofAsEpsilon)
                                                    if (c != null)
                                                      int newDepth = depth
                                                      if (config.state instanceof RuleStopState)
                                                        assert !fullCtx
                                                        # target fell off end of rule mark resulting c as having dipped into outer context
                                                        # We can't get here if incoming config was rule stop and we had context
                                                        # track how far we dip into outer context.  Might
                                                        # come in handy and we avoid evaluating context dependent
                                                        # preds if this is > 0.

                                                        if (_dfa != null && _dfa.isPrecedenceDfa())
                                                          int outermostPrecedenceReturn = ((EpsilonTransition) t).outermostPrecedenceReturn()
                                                          if (outermostPrecedenceReturn == _dfa.atnStartState.ruleIndex)
                                                            c.setPrecedenceFilterSuppressed(true)
                                                          end
                                                        end

                                                        c.reachesIntoOuterContext + +

                                                        if (!closureBusy.add(c))
                                                          # avoid infinite recursion for right-recursive rules
                                                          continue
                                                        end

                                                        configs.dipsIntoOuterContext = true # TODO: can remove? only care when we add to set per middle of this method
                                                        assert newDepth > Integer.MIN_VALUE
                                                        newDepth - -
                                                        if (debug)
                                                          System.out.println("dips into outer ctx: " + c)
                                                        end
                                                      else
                                                        if (!t.isEpsilon() && !closureBusy.add(c))
                                                          # avoid infinite recursion for EOF* and EOF+
                                                          continue
                                                        end

                                                        if (t instanceof RuleTransition)
                                                          # latch when newDepth goes negative - once we step out of the entry context we can't return
                                                          if (newDepth >= 0)
                                                            newDepth + +
                                                          end
                                                        end
                                                      end

                                                      closureCheckingStopState(c, configs, closureBusy, continueCollecting,
                                                                               fullCtx, newDepth, treatEofAsEpsilon)
                                                    end
                                                  end
                                                end


                                                protected boolean canDropLoopEntryEdgeInLeftRecursiveRule(ATNConfig config)
                                                if (TURN_OFF_LR_LOOP_ENTRY_BRANCH_OPT)
                                                  return false
                                                  ATNState p = config.state
                                                  # First check to see if we are in StarLoopEntryState generated during
                                                  # left-recursion elimination. For efficiency, also check if
                                                  # the context has an empty stack case. If so, it would mean
                                                  # global FOLLOW so we can't perform optimization
                                                  if (p.getStateType() != ATNState.STAR_LOOP_ENTRY ||
                                                      !((StarLoopEntryState) p).isPrecedenceDecision || # Are we the special loop entry/exit state?
                                                      config.context.isEmpty() || # If SLL wildcard
                                                      config.context.hasEmptyPath())

                                                    return false
                                                  end

                                                  # Require all return states to return back to the same rule
                                                  # that p is in.
                                                  int numCtxs = config.context.size()
                                                  for (int i = 0 i < numCtxs
                                                    i + +) # for each stack context
                                                    ATNState returnState = atn.states.get(config.context.getReturnState(i))
                                                    if (returnState.ruleIndex != p.ruleIndex)
                                                      return false
                                                    end

                                                    BlockStartState decisionStartState = (BlockStartState) p.transition(0).target
                                                    int blockEndStateNum = decisionStartState.endState.stateNumber
                                                    BlockEndState blockEndState = (BlockEndState) atn.states.get(blockEndStateNum)

                                                    # Verify that the top of each stack context leads to loop entry/exit
                                                    # state through epsilon edges and w/o leaving rule.
                                                    for (int i = 0 i < numCtxs
                                                      i + +) # for each stack context
                                                      int returnStateNumber = config.context.getReturnState(i)
                                                      ATNState returnState = atn.states.get(returnStateNumber)
                                                      # all states must have single outgoing epsilon edge
                                                      if (returnState.getNumberOfTransitions() != 1 ||
                                                          !returnState.transition(0).isEpsilon())

                                                        return false
                                                      end
                                                      # Look for prefix op case like 'not expr', (' type ')' expr
                                                      ATNState returnStateTarget = returnState.transition(0).target
                                                      if (returnState.getStateType() == BLOCK_END && returnStateTarget == p)
                                                        continue
                                                      end
                                                      # Look for 'expr op expr' or case where expr's return state is block end
                                                      # of (...)* internal block the block end points to loop back
                                                      # which points to p but we don't need to check that
                                                      if (returnState == blockEndState)
                                                        continue
                                                      end
                                                      # Look for ternary expr ? expr : expr. The return state points at block end,
                                                      # which points at loop entry state
                                                      if (returnStateTarget == blockEndState)
                                                        continue
                                                      end
                                                      # Look for complex prefix 'between expr and expr' case where 2nd expr's
                                                      # return state points at block end state of (...)* internal block
                                                      if (returnStateTarget.getStateType() == BLOCK_END &&
                                                          returnStateTarget.getNumberOfTransitions() == 1 &&
                                                          returnStateTarget.transition(0).isEpsilon() &&
                                                          returnStateTarget.transition(0).target == p)

                                                        continue
                                                      end

                                                      # anything else ain't conforming
                                                      return false
                                                    end

                                                    return true
                                                  end


                                                  public String getRuleName(int index)
                                                  if (parser != null && index >= 0)
                                                    return parser.getRuleNames()[index]
                                                    return "<rule " + index + ">"
                                                  end


                                                  protected ATNConfig getEpsilonTarget(ATNConfig config,
                                                                                                 Transition t,
                                                                                                            boolean collectPredicates,
                                                                                                                    boolean inContext,
                                                                                                                            boolean fullCtx,
                                                                                                                                    boolean treatEofAsEpsilon)

                                                  switch (t.getSerializationType())
                                                  case Transition.RULE :
                                                      return ruleTransition(config, (RuleTransition) t)

                                                  case Transition.PRECEDENCE :
                                                      return precedenceTransition(config, (PrecedencePredicateTransition) t, collectPredicates, inContext, fullCtx)

                                                  case Transition.PREDICATE :
                                                      return predTransition(config, (PredicateTransition) t,
                                                      collectPredicates,
                                                      inContext,
                                                      fullCtx)

                                                  case Transition.ACTION :
                                                      return actionTransition(config, (ActionTransition) t)

                                                  case Transition.EPSILON :
                                                      return new ATNConfig(config, t.target)

                                                  case Transition.ATOM :
                                                      case Transition.RANGE :
                                                      case Transition.SET :
                                                  # EOF transitions act like epsilon transitions after the first EOF
                                                  # transition is traversed
                                                      if (treatEofAsEpsilon)
                                                        if (t.matches(Token.EOF, 0, 1))
                                                          return new ATNConfig(config, t.target)
                                                        end
                                                      end

                                                  return null

                                                  default :
                                                      return null
                                                end
                                              end


                                     protected ATNConfig actionTransition(ATNConfig config, ActionTransition t)
                                     if (debug)
                                       System.out.println("ACTION edge " + t.ruleIndex + ":" + t.actionIndex)
                                       return new ATNConfig(config, t.target)
                                     end


                                     public ATNConfig precedenceTransition(ATNConfig config,
                                                                                     PrecedencePredicateTransition pt,
                                                                                                                   boolean collectPredicates,
                                                                                                                           boolean inContext,
                                                                                                                                   boolean fullCtx)

                                     if (debug)
                                       System.out.println("PRED (collectPredicates=" + collectPredicates + ") " +
                                                              pt.precedence + ">=_p" +
                                                              ", ctx dependent=true")
                                       if (parser != null)
                                         System.out.println("context surrounding pred is " +
                                                                parser.getRuleInvocationStack())
                                       end
                                     end

                                     ATNConfig c = null
                                     if (collectPredicates && inContext)
                                       if (fullCtx)
                                         # In full context mode, we can evaluate predicates on-the-fly
                                         # during closure, which dramatically reduces the size of
                                         # the config sets. It also obviates the need to test predicates
                                         # later during conflict resolution.
                                         int currentPosition = _input.index()
                                         _input.seek(_startIndex)
                                         boolean predSucceeds = evalSemanticContext(pt.getPredicate(), _outerContext, config.alt, fullCtx)
                                         _input.seek(currentPosition)
                                         if (predSucceeds)
                                           c = new ATNConfig(config, pt.target) # no pred context
                                         end
                                       end
                                     else
                                       SemanticContext newSemCtx =
                                                           SemanticContext.and(config.semanticContext, pt.getPredicate())
                                       c = new ATNConfig(config, pt.target, newSemCtx)
                                     end
                                   end
else
c = new ATNConfig(config, pt.target)
end

if (debug)
  System.out.println("config from pred transition=" + c)
  return c
end


protected ATNConfig predTransition(ATNConfig config,
                                             PredicateTransition pt,
                                                                 boolean collectPredicates,
                                                                         boolean inContext,
                                                                                 boolean fullCtx)

if (debug)
  System.out.println("PRED (collectPredicates=" + collectPredicates + ") " +
                         pt.ruleIndex + ":" + pt.predIndex +
                         ", ctx dependent=" + pt.isCtxDependent)
  if (parser != null)
    System.out.println("context surrounding pred is " +
                           parser.getRuleInvocationStack())
  end
end

ATNConfig c = null
if (collectPredicates &&
    (!pt.isCtxDependent || (pt.isCtxDependent && inContext)))

  if (fullCtx)
    # In full context mode, we can evaluate predicates on-the-fly
    # during closure, which dramatically reduces the size of
    # the config sets. It also obviates the need to test predicates
    # later during conflict resolution.
    int currentPosition = _input.index()
    _input.seek(_startIndex)
    boolean predSucceeds = evalSemanticContext(pt.getPredicate(), _outerContext, config.alt, fullCtx)
    _input.seek(currentPosition)
    if (predSucceeds)
      c = new ATNConfig(config, pt.target) # no pred context
    end
  end
else
  SemanticContext newSemCtx =
                      SemanticContext.and(config.semanticContext, pt.getPredicate())
  c = new ATNConfig(config, pt.target, newSemCtx)
end
end
else
c = new ATNConfig(config, pt.target)
end

if (debug)
  System.out.println("config from pred transition=" + c)
  return c
end


protected ATNConfig ruleTransition(ATNConfig config, RuleTransition t)
if (debug)
  System.out.println("CALL rule " + getRuleName(t.target.ruleIndex) +
                         ", ctx=" + config.context)
end

ATNState returnState = t.followState
PredictionContext newContext =
                      SingletonPredictionContext.create(config.context, returnState.stateNumber)
return new ATNConfig(config, t.target, newContext)
end


protected BitSet getConflictingAlts(ATNConfigSet configs)
Collection < BitSet > altsets = PredictionMode.getConflictingAltSubsets(configs)
return PredictionMode.getAlts(altsets)
end


Sam pointed out a problem with the previous definition, v3, of
ambiguous states.If we have another state associated with conflicting
alternatives, we should keep going.For example, the following grammar

s : (ID | ID ID?) ''

When the ATN simulation reaches the state before '', it has a DFA
state that looks like: [12 | 1 | [], 6 | 2 | [], 12 | 2 | []].Naturally
12 | 1 | [] and 12 | 2 | [] conflict, but we cannot stop processing this node
because alternative to has another way to continue, via [6 | 2 | []].
    The key is that we have a single state that has config 's only associated
	 with a single alternative, 2, and crucially the state transitions
	 among the configurations are all non-epsilon transitions. That means
	 we don' t consider any conflicts that include alternative 2.So, we
ignore the conflict between alts 1 and 2.We ignore a set of
conflicting alts when there is an intersection with an alternative
associated with a single alt state in the state & rarrconfig - list map.

    It 's also the case that we might have two conflicting configurations but
	 also a 3rd nonconflicting configuration for a different alternative:
	 [1|1|[], 1|2|[], 8|3|[]]. This can come about from grammar:

	 a : A | A | A B 

	 After matching input A, we reach the stop state for rule A, state 1.
	 State 8 is the state right before B. Clearly alternatives 1 and 2
	 conflict and no amount of further lookahead will separate the two.
	 However, alternative 3 will be able to continue and so we do not
	 stop working on this state. In the previous example, we' re concerned
with states associated with the conflicting alternatives.Here alt
3 is not associated with the conflicting configs, but since we can continue
looking for input reasonably
          , I don 't declare the state done. We
	 ignore a set of conflicting alts when we have an alternative
	 that we still need to pursue.

	protected BitSet getConflictingAltsOrUniqueAlt(ATNConfigSet configs) 
		BitSet conflictingAlts
		if ( configs.uniqueAlt!= ATN.INVALID_ALT_NUMBER ) 
			conflictingAlts = new BitSet()
			conflictingAlts.set(configs.uniqueAlt)
		end
		else 
			conflictingAlts = configs.conflictingAlts
		end
		return conflictingAlts
	end


	public String getTokenName(int t) 
		if (t == Token.EOF) 
			return "EOF"
		end

		Vocabulary vocabulary = parser != null ? parser.getVocabulary() : VocabularyImpl.EMPTY_VOCABULARY
		String displayName = vocabulary.getDisplayName(t)
		if (displayName.equals(Integer.to_s(t))) 
			return displayName
		end

		return displayName + "<" + t + ">"
	end

	public String getLookaheadName(TokenStream input) 
		return getTokenName(input.LA(1))
	end





	public void dumpDeadEndConfigs(NoViableAltException nvae) 
		System.err.println("dead end configs: ")
		for (ATNConfig c : nvae.getDeadEndConfigs()) 
			String trans = "no edges"
			if ( c.state.getNumberOfTransitions()>0 ) 
				Transition t = c.state.transition(0)
				if ( t instanceof AtomTransition) 
					AtomTransition at = (AtomTransition)t
					trans = "Atom "+getTokenName(at.label)
				end
				else if ( t instanceof SetTransition ) 
					SetTransition st = (SetTransition)t
					boolean not = st instanceof NotSetTransition
					trans = (not?"~":"")+"Set "+st.set.to_s()
				end
			end
			System.err.println(c.to_s(parser, true)+":"+trans)
		end
	end


	protected NoViableAltException noViableAlt(TokenStream input,
											ParserRuleContext outerContext,
											ATNConfigSet configs,
											int startIndex)
	
		return new NoViableAltException(parser, input,
											input.get(startIndex),
											input.LT(1),
											configs, outerContext)
	end

	protected static int getUniqueAlt(ATNConfigSet configs) 
		int alt = ATN.INVALID_ALT_NUMBER
		for (ATNConfig c : configs) 
			if ( alt == ATN.INVALID_ALT_NUMBER ) 
				alt = c.alt # found first alt
			end
			else if ( c.alt!=alt ) 
				return ATN.INVALID_ALT_NUMBER
			end
		end
		return alt
	end





















	protected DFAState addDFAEdge(DFA dfa,
								  DFAState from,
								  int t,
								  DFAState to)
	
		if ( debug ) 
			System.out.println("EDGE "+from+" -> "+to+" upon "+getTokenName(t))
		end

		if (to == null) 
			return null
		end

		to = addDFAState(dfa, to) # used existing if possible not incoming
		if (from == null || t < -1 || t > atn.maxTokenType) 
			return to
		end

		synchronized (from) 
			if ( from.edges==null ) 
				from.edges = new DFAState[atn.maxTokenType+1+1]
			end

			from.edges[t+1] = to # connect
		end

		if ( debug ) 
			System.out.println("DFA=\n"+dfa.to_s(parser!=null?parser.getVocabulary():VocabularyImpl.EMPTY_VOCABULARY))
		end

		return to
	end
















	protected DFAState addDFAState(DFA dfa, DFAState D) 
		if (D == ERROR) 
			return D
		end

		synchronized (dfa.states) 
			DFAState existing = dfa.states.get(D)
			if ( existing!=null ) return existing

			D.stateNumber = dfa.states.size()
			if (!D.configs.isReadonly()) 
				D.configs.optimizeConfigs(this)
				D.configs.setReadonly(true)
			end
			dfa.states.put(D, D)
			if ( debug ) System.out.println("adding new DFA state: "+D)
			return D
		end
	end

	protected void reportAttemptingFullContext(DFA dfa, BitSet conflictingAlts, ATNConfigSet configs, int startIndex, int stopIndex) 
        if ( debug || retry_debug ) 
			Interval interval = Interval.of(startIndex, stopIndex)
			System.out.println("reportAttemptingFullContext decision="+dfa.decision+":"+configs+
                               ", input="+parser.getTokenStream().getText(interval))
        end
        if ( parser!=null ) parser.getErrorListenerDispatch().reportAttemptingFullContext(parser, dfa, startIndex, stopIndex, conflictingAlts, configs)
    end

	protected void reportContextSensitivity(DFA dfa, int prediction, ATNConfigSet configs, int startIndex, int stopIndex) 
        if ( debug || retry_debug ) 
			Interval interval = Interval.of(startIndex, stopIndex)
            System.out.println("reportContextSensitivity decision="+dfa.decision+":"+configs+
                               ", input="+parser.getTokenStream().getText(interval))
        end
        if ( parser!=null ) parser.getErrorListenerDispatch().reportContextSensitivity(parser, dfa, startIndex, stopIndex, prediction, configs)
    end


    protected void reportAmbiguity(DFA dfa,
								   DFAState D, # the DFA state from execATN() that had SLL conflicts
								   int startIndex, int stopIndex,
								   boolean exact,
								   BitSet ambigAlts,
								   ATNConfigSet configs) # configs that LL not SLL considered conflicting
	
		if ( debug || retry_debug ) 
			Interval interval = Interval.of(startIndex, stopIndex)
			System.out.println("reportAmbiguity "+
							   ambigAlts+":"+configs+
                               ", input="+parser.getTokenStream().getText(interval))
        end
        if ( parser!=null ) parser.getErrorListenerDispatch().reportAmbiguity(parser, dfa, startIndex, stopIndex,
																			  exact, ambigAlts, configs)
    end

	public final void setPredictionMode(PredictionMode mode) 
		this.mode = mode
	end


	public final PredictionMode getPredictionMode() 
		return mode
	end




	public Parser getParser() 
		return parser
	end

	def self.getSafeEnv(String envName) 
		try 
			return System.getenv(envName)
		end
		catch(SecurityException e) 
			# use the default value
		end
		return null
	end
end
