require '../antlr4/ATNSimulator'
require '../antlr4/PredictionMode'


class ParserATNSimulator < ATNSimulator
  @debug = false
  @debug_list_atn_decisions = false
  @dfa_debug = false
  @retry_debug = false

  attr_accessor :debug
  attr_accessor :debug_list_atn_decisions
  attr_accessor :dfa_debug
  attr_accessor :retry_debug

  def self.getSafeEnv(envName)
    begin
      return ENV[envName]

    rescue
# use the default value
    end

    return nil
  end

  TURN_OFF_LR_LOOP_ENTRY_BRANCH_OPT = getSafeEnv("TURN_OFF_LR_LOOP_ENTRY_BRANCH_OPT")

  @parser

  @decisionToDFA


  @mode = PredictionMode::LL


  @mergeCache = nil

  # LAME globals to avoid parameters!!!!! I need these down deep in predTransition
  @_input = nil
  @_startIndex = nil
  @_outerContext = nil
  @_dfa = nil


  def initialize(parser, atn, decisionToDFA, sharedContextCache)

    super(atn, sharedContextCache)
    @parser = parser
    @decisionToDFA = decisionToDFA
  end


  def reset()
  end


  def clearDFA()
    d = 0
    while d < decisionToDFA.length
      @decisionToDFA[d] = new DFA(atn.getDecisionState(d), d)
    end
  end

  def adaptivePredict(input, decision, outerContext)

    if (@debug || @debug_list_atn_decisions)
      puts("adaptivePredict decision " + decision +
               " exec LA(1)==" + getLookaheadName(input) +
               " line " + input.LT(1).getLine() + ":" + input.LT(1).getCharPositionInLine())
    end

    @_input = input
    @_startIndex = input.index()
    @_outerContext = outerContext
    dfa = @decisionToDFA[decision]
    @_dfa = dfa

    m = input.mark()
    index = @_startIndex

    # Now we are certain to have a specific decision's DFA
    # But, do we still need an initial state?
    begin
      s0 = nil
      if (dfa.isPrecedenceDfa())
        # the start state for a precedence DFA depends on the current
        # parser precedence, and is provided by a DFA method.
        s0 = dfa.getPrecedenceStartState(parser.getPrecedence())
      else
# the start state for a "regular" DFA is just s0
        s0 = dfa.s0
      end

      if (s0 == nil)
        if (outerContext == nil)
          outerContext = ParserRuleContext.EMPTY
        end
        if (@debug || @debug_list_atn_decisions)
          puts("predictATN decision " + dfa.decision +
                   " exec LA(1)==" + getLookaheadName(input) +
                   ", outerContext=" + outerContext.to_s(@parser))
        end

        fullCtx = false
        s0_closure =
            computeStartState(dfa.atnStartState,
                              ParserRuleContext.EMPTY,
                              fullCtx)

        if (dfa.isPrecedenceDfa())
          dfa.s0.configs = s0_closure # not used for prediction but useful to know start configs anyway
          s0_closure = applyPrecedenceFilter(s0_closure)
          s0 = addDFAState(dfa, DFAState.new(s0_closure))
          dfa.setPrecedenceStartState(@parser.getPrecedence(), s0)
        else
          s0 = addDFAState(dfa, DFAState.new(s0_closure))
          dfa.s0 = s0
        end
      end

      alt = execATN(dfa, s0, input, index, outerContext)
      if (debug)
        puts("DFA after predictATN: " + dfa.to_s(parser.getVocabulary()))
      end
      return alt
    ensure
      @mergeCache = nil # wack cache after each prediction
      @_dfa = nil
      input.seek(index)
      input.release(m)
    end
  end

  def execATN(dfa, s0, input, startIndex, outerContext)

    if (@debug || @debug_list_atn_decisions)
      puts("execATN decision " + dfa.decision +
               " exec LA(1)==" + getLookaheadName(input) +
               " line " + input.LT(1).getLine() + ":" + input.LT(1).getCharPositionInLine())
    end

    previousD = s0

    if (@debug)
      puts("s0 = " + s0)
    end

    t = input.LA(1)

    while (true) # while more work
      d = getExistingTargetState(previousD, t)
      if (d == nil)
        d = computeTargetState(dfa, previousD, t)
      end

      if (d == ERROR)
        # if any configs in previous dipped into outer context, that
        # means that input up to t actually finished entry rule
        # at least for SLL decision. Full LL doesn' t dip into outer
        # so don't need special case.
        # We will get an error no matter what so delay until after
        # decision better error message. Also, no reachable target
        # ATN states in SLL implies LL will also get nowhere.
        # If conflict in states that dip out, choose min since we
        # will get error no matter what.
        input.seek(startIndex)
        alt = getSynValidOrSemInvalidAltThatFinishedDecisionEntryRule(previousD.configs, outerContext)
        if (alt != ATN.INVALID_ALT_NUMBER)
          return alt
        end
        raise NoViableAltException, input, outerContext, previousD.configs, startIndex
      end

      if (d.requiresFullContext && @mode != PredictionMode.SLL)
        # IF PREDS, MIGHT RESOLVE TO SINGLE ALT => SLL (or syntax error)
        conflictingAlts = d.configs.conflictingAlts
        if (d.predicates != nil)
          if (@debug)
            puts("DFA state has preds in DFA sim LL failover")
          end
          conflictIndex = input.index()
          if (conflictIndex != startIndex)
            input.seek(startIndex)
          end

          conflictingAlts = evalSemanticContext(D.predicates, outerContext, true)
          if (conflictingAlts.cardinality() == 1)
            if (debug)
              puts("Full LL avoided")
            end
            return conflictingAlts.nextSetBit(0)
          end

          if (conflictIndex != startIndex)
            # restore the index so reporting the fallback to full
            # context occurs with the index at the correct spot
            input.seek(conflictIndex)
          end
        end

        if (@dfa_debug)
          puts("ctx sensitive state " + outerContext + " in " + d)
        end
        fullCtx = true
        s0_closure =
            computeStartState(dfa.atnStartState, outerContext,
                              fullCtx)
        reportAttemptingFullContext(dfa, conflictingAlts, d.configs, startIndex, input.index())
        alt = execATNWithFullContext(dfa, d, s0_closure,
                                     input, startIndex,
                                     outerContext)
        return alt
      end

      if (d.isAcceptState)
        if (d.predicates == nil)
          return d.prediction
        end

        stopIndex = input.index()
        input.seek(startIndex)
        alts = evalSemanticContext(d.predicates, outerContext, true)
        case (alts.cardinality())
        when 0
          raise NoViableAltException, input, outerContext, d.configs, startIndex

        when 1
          return alts.nextSetBit(0)

        else
          # report ambiguity after predicate evaluation to make sure the correct
          # set of ambig alts is reported.
          reportAmbiguity(dfa, D, startIndex, stopIndex, false, alts, d.configs)
          return alts.nextSetBit(0)
        end
      end

      previousD = d

      if (t != IntStream.EOF)
        input.consume()
        t = input.LA(1)
      end
    end
  end


  def getExistingTargetState(previousD, t)
    edges = previousD.edges
    if (edges == nil || t + 1 < 0 || t + 1 >= edges.length)
      return nil
    end

    return edges[t + 1]
  end


  def computeTargetState(dfa, previousD, t)
    reach = computeReachSet(previousD.configs, t, false)
    if (reach == nil)
      addDFAEdge(dfa, previousD, t, ERROR)
      return ERROR
    end

    # create new target state we'll add to DFA after it's complete
    d = DFAState.new(reach)

    predictedAlt = getUniqueAlt(reach)

    if (@debug)
      altSubSets = PredictionMode.getConflictingAltSubsets(reach)
      puts("SLL altSubSets=" + altSubSets +
               ", configs=" + reach +
               ", predict=" + predictedAlt + ", allSubsetsConflict=" +
               PredictionMode.allSubsetsConflict(altSubSets) + ", conflictingAlts=" +
               getConflictingAlts(reach))
    end

    if (predictedAlt != ATN.INVALID_ALT_NUMBER)
      # NO CONFLICT, UNIQUELY PREDICTED ALT
      d.isAcceptState = true
      d.configs.uniqueAlt = predictedAlt
      d.prediction = predictedAlt
    elsif (PredictionMode.hasSLLConflictTerminatingPrediction(mode, reach))
      # MORE THAN ONE VIABLE ALTERNATIVE
      d.configs.conflictingAlts = getConflictingAlts(reach)
      d.requiresFullContext = true
      # in SLL-only mode, we will stop at this state and return the minimum alt
      d.isAcceptState = true
      d.prediction = d.configs.conflictingAlts.nextSetBit(0)
    end

    if (d.isAcceptState && d.configs.hasSemanticContext)
      predicateDFAState(d, atn.getDecisionState(dfa.decision))
      if (d.predicates != nil)
        d.prediction = ATN.INVALID_ALT_NUMBER
      end
    end

    # all adds to dfa are done after we've created full D state
    d = addDFAEdge(dfa, previousD, t, d)
    return d
  end

  def predicateDFAState(dfaState, decisionState)
    # We need to test all predicates, even in DFA states that
    # uniquely predict alternative.
    nalts = decisionState.getNumberOfTransitions()
    # Update DFA so reach becomes accept state with (predicate,alt)
    # pairs if preds found for conflicting alts
    altsToCollectPredsFrom = getConflictingAltsOrUniqueAlt(dfaState.configs)
    altToPred = getPredsForAmbigAlts(altsToCollectPredsFrom, dfaState.configs, nalts)
    if (altToPred != nil)
      dfaState.predicates = getPredicatePredictions(altsToCollectPredsFrom, altToPred)
      dfaState.prediction = ATN.INVALID_ALT_NUMBER # make sure we use preds
    else
# There are preds in configs but they might go away
# when OR'd together like pend? || NONE == NONE. If neither
# alt has preds, resolve to min alt
      dfaState.prediction = altsToCollectPredsFrom.nextSetBit(0)
    end
  end

  # comes back with reach.uniqueAlt set to a valid alt
  def execATNWithFullContext(dfa, d, s0, input, startIndex, outerContext)

    if (@debug || @debug_list_atn_decisions)
      puts("execATNWithFullContext " + s0)
    end
    fullCtx = true
    foundExactAmbig = false
    reach = nil
    previous = s0
    input.seek(startIndex)
    t = input.LA(1)
    predictedAlt = 0
    while (true) # while more work

      reach = computeReachSet(previous, t, fullCtx)
      if (reach == nil)
        # if any configs in previous dipped into outer context, that
        # means that input up to t actually finished entry rule
        # at least for LL decision. Full LL doesn't dip into outer
        # so don't need special case.
        # We will get an error no matter what so delay until after
        # decision better error message. Also, no reachable target
        # ATN states in SLL implies LL will also get nowhere.
        # If conflict in states that dip out, choose min since we
        # will get error no matter what.

        input.seek(startIndex)
        alt = getSynValidOrSemInvalidAltThatFinishedDecisionEntryRule(previous, outerContext)
        if (alt != ATN.INVALID_ALT_NUMBER)
          return alt
        end
        raise NoViableAltException, input, outerContext, previous, startIndex
      end

      altSubSets = PredictionMode.getConflictingAltSubsets(reach)
      if (@debug)
        puts("LL altSubSets=" + altSubSets +
                 ", predict=" + PredictionMode.getUniqueAlt(altSubSets) +
                 ", resolvesToJustOneViableAlt=" +
                 PredictionMode.resolvesToJustOneViableAlt(altSubSets))
      end

#			puts("altSubSets: "+altSubSets)
#			System.err.println("reach="+reach+", "+reach.conflictingAlts)
      reach.uniqueAlt = getUniqueAlt(reach)
# unique prediction?
      if (reach.uniqueAlt != ATN.INVALID_ALT_NUMBER)
        predictedAlt = reach.uniqueAlt
        break
      end
      if (@mode != PredictionMode.LL_EXACT_AMBIG_DETECTION)
        predictedAlt = PredictionMode.resolvesToJustOneViableAlt(altSubSets)
        if (predictedAlt != ATN.INVALID_ALT_NUMBER)
          break
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

    reportAmbiguity(dfa, d, startIndex, input.index(), foundExactAmbig,
                    reach.getAlts(), reach)

    return predictedAlt
  end

  def computeReachSet(closure, t, fullCtx)

    if (@debug)
      puts("in computeReachSet, starting closure: " + closure)
    end

    if (@mergeCache == nil)
      mergeCache = Hash.new
    end

    intermediate = ATNConfigSet.new(fullCtx)


    skippedStopStates = nil

    # First figure out where we can reach on input t
    closure.each do |c|
      if (@debug)
        puts("testing " + getTokenName(t) + " at " + c.to_s())
      end

      if (c.state.is_a? RuleStopState)
        if (fullCtx || t == IntStream.EOF)
          if (skippedStopStates == nil)
            skippedStopStates = []
          end

          skippedStopStates.add(c)
        end

        next
      end

      n = c.state.getNumberOfTransitions()
      ti = 0
      while ti < n
        ti
        trans = c.state.transition(ti)
        target = getReachableTarget(trans, t)
        if (target != nil)
          intermediate.add(ATNConfig.new(c, target), mergeCache)
        end
      end
    end

    # Now figure out where the reach operation can take us...

    reach = nil


    if (skippedStopStates == nil && t != Token::EOF)
      if (intermediate.size() == 1)
        # Don' t pursue the closure if there is just one state.
        # It can only have one alternative just add to result
        # Also don't pursue the closure if there is unique alternative
        # among the configurations.
        reach = intermediate
      elsif (getUniqueAlt(intermediate) != ATN::INVALID_ALT_NUMBER)
        # Also don't pursue the closure if there is unique alternative
        # among the configurations.
        reach = intermediate
      end
    end


    if (reach == nil)
      reach = ATNConfigSet.new(fullCtx)
      closureBusy = Set.new
      treatEofAsEpsilon = t == Token::EOF
      intermediate.each do |c|
        closure(c, reach, closureBusy, false, fullCtx, treatEofAsEpsilon)
      end
    end

    if (t == IntStream.EOF)
      reach = removeAllConfigsNotInRuleStopState(reach, reach == intermediate)
    end


    if (skippedStopStates != nil && (!fullCtx || !PredictionMode.hasConfigInRuleStopState(reach)))
      skippedStopStates.each do |c|
        reach.add(c, mergeCache)
      end
    end

    if (reach.isEmpty())
      return nil
    end
    return reach
  end


  def removeAllConfigsNotInRuleStopState(configs, lookToEndOfRule)
    if (PredictionMode.allConfigsInRuleStopStates(configs))
      return configs
    end

    result = ATNConfigSet.new(configs.fullCtx)
    configs.each do |config|
      if (config.state.is_a? RuleStopState)
        result.add(config, mergeCache)
        next
      end

      if (lookToEndOfRule && config.state.onlyHasEpsilonTransitions())
        nextTokens = atn.nextTokens(config.state)
        if (nextTokens.include?(Token::EPSILON))
          endOfRuleState = atn.ruleToStopState[config.state.ruleIndex]
          result.add(ATNConfig.new(config, endOfRuleState), @mergeCache)
        end
      end
    end

    return result
  end


  def computeStartState(p, ctx, fullCtx)

    # always at least the implicit call to start rule
    initialContext = PredictionContext.fromRuleContext(@atn, ctx)
    configs = ATNConfigSet.new(fullCtx)

    i = 0
    while i < p.getNumberOfTransitions()
      target = p.transition(i).target
      c = ATNConfig.new(target, i + 1, initialContext)
      closureBusy = Set.new
      closure(c, configs, closureBusy, true, fullCtx, false)
      i += 1
    end

    return configs
  end

  def applyPrecedenceFilter(configs)
    statesFromAlt1 = Map.new
    configSet = ATNConfigSet.new(configs.fullCtx)
    configs.each do |config|
      # handle alt 1 first
      if (config.alt != 1)
        next
      end

      updatedContext = config.semanticContext.evalPrecedence(parser, _outerContext)
      if (updatedContext == nil)
        # the configuration was eliminated
        next
      end

      statesFromAlt1.put(config.state.stateNumber, config.context)
      if (updatedContext != config.semanticContext)
        configSet.add(ATNConfig.new(config, updatedContext), @mergeCache)
      else
        configSet.add(config, mergeCache)
      end
    end

    configs.each do |config|
      if (config.alt == 1)
        # already handled
        next
      end

      if (!config.isPrecedenceFilterSuppressed())


        context = statesFromAlt1.get(config.state.stateNumber)
        if (context != nil && context.equals(config.context))
          # eliminated
          next
        end
      end

      configSet.add(config, @mergeCache)
    end

    return configSet
  end

  def getReachableTarget(trans, ttype)
    if (trans.matches(ttype, 0, atn.maxTokenType))
      return trans.target
    end

    return nil
  end

  def getPredsForAmbigAlts(ambigAlts, configs, nalts)

    altToPred = []
    configs.each do |c|
      if (ambigAlts.get(c.alt))
        altToPred[c.alt] = SemanticContext.or(altToPred[c.alt], c.semanticContext)
      end
    end

    nPredAlts = 0
    i = 1
    while i <= nalts
      if (altToPred[i] == nil)
        altToPred[i] = SemanticContext::NONE
      elsif (altToPred[i] != SemanticContext::NONE)
        nPredAlts += 1
      end
      i += 1
    end

    # nonambig alts are nil in altToPred
    if (nPredAlts == 0)
      altToPred = nil
    end
    if (@debug)
      puts("getPredsForAmbigAlts result " + altToPred.to_s)
    end
    return altToPred
  end

  def getPredicatePredictions(ambigAlts, altToPred)

    pairs = []
    containsPredicate = false
    i = 1
    while i < altToPred.length
      pred = altToPred[i]

      if (ambigAlts != nil && ambigAlts.get(i))
        pairs.add(DFAState.PredPrediction.new(pred, i))
      end
      if (pred != SemanticContext::NONE)
        containsPredicate = true
      end
      i += 1
    end

    if (!containsPredicate)
      return nil
    end

    #		puts(Arrays.to_s(altToPred)+"->"+pairs)
    return pairs.toArray()
  end


  def getSynValidOrSemInvalidAltThatFinishedDecisionEntryRule(configs, outerContext)

    sets = splitAccordingToSemanticValidity(configs, outerContext)
    semValidConfigs = sets.a
    semInvalidConfigs = sets.b
    alt = getAltThatFinishedDecisionEntryRule(semValidConfigs)
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

  def getAltThatFinishedDecisionEntryRule(configs)
    alts = IntervalSet.new
    configs.each do |c|
      if (c.getOuterContextDepth() > 0 || (c.state.is_a? RuleStopState && c.context.hasEmptyPath()))
        alts.add(c.alt)
      end
    end
    if (alts.size() == 0)
      return ATN.INVALID_ALT_NUMBER
    end
    return alts.getMinElement()
  end


  def splitAccordingToSemanticValidity(configs, outerContext)

    succeeded = ATNConfigSet.new(configs.fullCtx)
    failed = ATNConfigSet.new(configs.fullCtx)
    configs.each do |c|
      if (c.semanticContext != SemanticContext::NONE)
        predicateEvaluationResult = evalSemanticContext(c.semanticContext, outerContext, c.alt, configs.fullCtx)
        if (predicateEvaluationResult)
          succeeded.add(c)
        else
          failed.add(c)
        end
      else
        succeeded.add(c)
      end
    end

    pair = OpenStruct.new
    pair.a = succeeded
    pair.b = failed
    return pair
  end


  def evalSemanticContext_1(predPredictions, outerContext, complete)

    predictions = BitSet.new
    predPredictions.each do |pair|
      if (pair.pred == SemanticContext::NONE)
        predictions.set(pair.alt)
        if (!complete)
          break
        end
        next
      end

      fullCtx = false # in dfa
      predicateEvaluationResult = evalSemanticContext(pair.pred, outerContext, pair.alt, fullCtx)
      if (@debug || @dfa_debug)
        puts("eval pred " + pair + "=" + predicateEvaluationResult)
      end

      if (predicateEvaluationResult)
        if (@debug || @dfa_debug)
          puts("PREDICT " + pair.alt)
        end
        predictions.set(pair.alt)
        if (!complete)
          break
        end
      end
    end

    return predictions
  end


  def evalSemanticContext_2(pred, parserCallStack, alt, fullCtx)
    return pred.eval(parser, parserCallStack)
  end


  def closure(config, configs, closureBusy, collectPredicates, fullCtx, treatEofAsEpsilon)

    initialDepth = 0
    closureCheckingStopState(config, configs, closureBusy, collectPredicates,
                             fullCtx,
                             initialDepth, treatEofAsEpsilon)
  end

  def closureCheckingStopState(config, configs, closureBusy, collectPredicates, fullCtx, depth, treatEofAsEpsilon)

    if (@debug)
      puts("closure(" + config.to_s(@parser, true) + ")")
    end

    if (config.state.is_a? RuleStopState)
      # We hit rule end. If we have context info, use it
      # run thru all possible stack tops in ctx
      if (!config.context.isEmpty())
        i = 0
        while i < config.context.size()
          if (config.context.getReturnState(i) == PredictionContext.EMPTY_RETURN_STATE)
            if (fullCtx)
              configs.add(ATNConfig.new(config, config.state, PredictionContext.EMPTY), @mergeCache)
              i += 1
              next
            else
              # we have no context info, just chase follow links (if greedy)
              if (@debug)
                puts("FALLING off rule " +
                         getRuleName(config.state.ruleIndex))
              end
              closure_(config, configs, closureBusy, collectPredicates,
                       fullCtx, depth, treatEofAsEpsilon)
            end
            i += 1
            next
          end
          returnState = atn.states.get(config.context.getReturnState(i))
          newContext = config.context.getParent(i) # "pop" return state
          c = ATNConfig.new(returnState, config.alt, newContext,
                            config.semanticContext)
          # While we have context to pop back from, we may have
          # gotten that context AFTER having falling off a rule.
          # Make sure we track that we are now out of context.
          #
          # This assignment also propagates the
          # isPrecedenceFilterSuppressed() value to the new
          # configuration.
          c.reachesIntoOuterContext = config.reachesIntoOuterContext
          closureCheckingStopState(c, configs, closureBusy, collectPredicates,
                                   fullCtx, depth - 1, treatEofAsEpsilon)
          i += 1
        end
        return
      elsif (fullCtx)
        # reached end of start rule
        configs.add(config, mergeCache)
        return
      else
        # else if we have no context info, just chase follow links (if greedy)
        if (@debug)
          puts("FALLING off rule " +
                   getRuleName(config.state.ruleIndex))
        end
      end
    end

    closure_(config, configs, closureBusy, collectPredicates,
             fullCtx, depth, treatEofAsEpsilon)
  end


  def closure_(config, configs, closureBusy, collectPredicates, fullCtx, depth, treatEofAsEpsilon)
    p = config.state
    # optimization
    if (!p.onlyHasEpsilonTransitions())
      configs.add(config, @mergeCache)
      # make sure to not return here, because EOF transitions can act as
      # both epsilon transitions and non-epsilon transitions.
      #            if ( debug ) puts("added config "+configs)
    end

    i = 0
    while i < p.getNumberOfTransitions()
      if (i == 0 && canDropLoopEntryEdgeInLeftRecursiveRule(config))
        i += 1
        next
      end

      t = p.transition(i)
      continueCollecting =
          !(t.is_a? ActionTransition) && collectPredicates
      c = getEpsilonTarget(config, t, continueCollecting,
                           depth == 0, fullCtx, treatEofAsEpsilon)
      if (c != nil)
        newDepth = depth
        if (config.state.is_a? RuleStopState)
          # target fell off end of rule mark resulting c as having dipped into outer context
          # We can't get here if incoming config was rule stop and we had context
          # track how far we dip into outer context.  Might
          # come in handy and we avoid evaluating context dependent
          # preds if this is > 0.

          if (@_dfa != nil && @_dfa.isPrecedenceDfa())
            outermostPrecedenceReturn = t.outermostPrecedenceReturn()
            if (outermostPrecedenceReturn == @_dfa.atnStartState.ruleIndex)
              c.setPrecedenceFilterSuppressed(true)
            end
          end

          c.reachesIntoOuterContext += 1

          if (!closureBusy.add(c))
            # avoid infinite recursion for right-recursive rules
            i += 1
            next
          end

          configs.dipsIntoOuterContext = true # TODO: can remove? only care when we add to set per middle of this method
          newDepth -= 1
          if (@debug)
            puts("dips into outer ctx: " + c)
          end
        else
          if (!t.isEpsilon() && !closureBusy.add(c))
            # avoid infinite recursion for EOF* and EOF+
            i += 1
            next
          end

          if (t.is_a? RuleTransition)
            # latch when newDepth goes negative - once we step out of the entry context we can't return
            if (newDepth >= 0)
              newDepth += 1
            end
          end
        end

        closureCheckingStopState(c, configs, closureBusy, continueCollecting,
                                 fullCtx, newDepth, treatEofAsEpsilon)
      end
      i += 1
    end
  end


  def canDropLoopEntryEdgeInLeftRecursiveRule(config)
    if (TURN_OFF_LR_LOOP_ENTRY_BRANCH_OPT)
      return false
    end
    p = config.state
    # First check to see if we are in StarLoopEntryState generated during
    # left-recursion elimination. For efficiency, also check if
    # the context has an empty stack case. If so, it would mean
    # global FOLLOW so we can't perform optimization
    if (p.getStateType() != ATNState::STAR_LOOP_ENTRY ||
        !p.isPrecedenceDecision || # Are we the special loop entry/exit state?
        config.context.isEmpty() || # If SLL wildcard
        config.context.hasEmptyPath())

      return false
    end

    # Require all return states to return back to the same rule
    # that p is in.
    numCtxs = config.context.size()
    i = 0
    while i < numCtxs
      returnState = atn.states.get(config.context.getReturnState(i))
      if (returnState.ruleIndex != p.ruleIndex)
        return false
      end
      i += 1
    end

    decisionStartState = p.transition(0).target
    blockEndStateNum = decisionStartState.endState.stateNumber
    blockEndState = atn.states.get(blockEndStateNum)

    # Verify that the top of each stack context leads to loop entry/exit
    # state through epsilon edges and w/o leaving rule.
    i = 0
    while i < numCtxs
      returnStateNumber = config.context.getReturnState(i)
      returnState = atn.states.get(returnStateNumber)
      # all states must have single outgoing epsilon edge
      if (returnState.getNumberOfTransitions() != 1 ||
          !returnState.transition(0).isEpsilon())

        return false
      end
      # Look for prefix op case like 'not expr', (' type ')' expr
      returnStateTarget = returnState.transition(0).target
      if (returnState.getStateType() == BLOCK_END && returnStateTarget == p)
        i += 1
        next
      end
      # Look for 'expr op expr' or case where expr's return state is block end
      # of (...)* internal block the block end points to loop back
      # which points to p but we don't need to check that
      if (returnState == blockEndState)
        i += 1
        next
      end
      # Look for ternary expr ? expr : expr. The return state points at block end,
      # which points at loop entry state
      if (returnStateTarget == blockEndState)
        i += 1
        next
      end
      # Look for complex prefix 'between expr and expr' case where 2nd expr's
      # return state points at block end state of (...)* internal block
      if (returnStateTarget.getStateType() == BLOCK_END &&
          returnStateTarget.getNumberOfTransitions() == 1 &&
          returnStateTarget.transition(0).isEpsilon() &&
          returnStateTarget.transition(0).target == p)

        i += 1
        next
      end

      # anything else ain't conforming
      return false
    end

    return true
  end


  def getRuleName(index)
    if (@parser != nil && index >= 0)
      return @parser.getRuleNames()[index]
    end
    return "<rule " + index + ">"
  end


  def getEpsilonTarget(config, t, collectPredicates, inContext, fullCtx, treatEofAsEpsilon)

    case (t.getSerializationType())
    when Transition::RULE
      return ruleTransition(config, t)

    when Transition::PRECEDENCE
      return precedenceTransition(config, t, collectPredicates, inContext, fullCtx)

    when Transition::PREDICATE
      return predTransition(config, t,
                            collectPredicates,
                            inContext,
                            fullCtx)

    when Transition::ACTION
      return actionTransition(config, t)

    when Transition::EPSILON
      return ATNConfig.new(config, t.target)

    when Transition::ATOM, Transition::RANGE, Transition::SET
      # EOF transitions act like epsilon transitions after the first EOF
      # transition is traversed
      if (treatEofAsEpsilon)
        if (t.matches(Token::EOF, 0, 1))
          return ATNConfig.new(config, t.target)
        end
      end

      return nil

    else
      return nil
    end
  end


  def actionTransition(config, t)
    if (@debug)
      puts("ACTION edge " + t.ruleIndex + ":" + t.actionIndex)
    end
    return ATNConfig.new(config, t.target)
  end


  def precedenceTransition(config, pt, collectPredicates, inContext, fullCtx)

    if (@debug)
      puts("PRED (collectPredicates=" + collectPredicates + ") " +
               pt.precedence + ">=_p" +
               ", ctx dependent=true")
      if (@parser != nil)
        puts("context surrounding pred is " +
                 @parser.getRuleInvocationStack())
      end
    end

    c = nil
    if (collectPredicates && inContext)
      if (fullCtx)
        # In full context mode, we can evaluate predicates on-the-fly
        # during closure, which dramatically reduces the size of
        # the config sets. It also obviates the need to test predicates
        # later during conflict resolution.
        currentPosition = @_input.index()
        @_input.seek(@_startIndex)
        predSucceeds = evalSemanticContext(pt.getPredicate(), @_outerContext, config.alt, fullCtx)
        @_input.seek(currentPosition)
        if (predSucceeds)
          c = ATNConfig.new(config, pt.target) # no pred context
        end
      else
        newSemCtx = SemanticContext.and(config.semanticContext, pt.getPredicate())
        c = ATNConfig.new(config, pt.target, newSemCtx)
      end
    else
      c = ATNConfig.new(config, pt.target)
    end

    if (@debug)
      puts("config from pred transition=" + c)
    end
    return c
  end


  def predTransition(config, pt, collectPredicates, inContext, fullCtx)

    if (@debug)
      puts("PRED (collectPredicates=" + collectPredicates + ") " +
               pt.ruleIndex + ":" + pt.predIndex +
               ", ctx dependent=" + pt.isCtxDependent)
      if (@parser != nil)
        puts("context surrounding pred is " +
                 @parser.getRuleInvocationStack())
      end
    end

    c = nil
    if (collectPredicates &&
        (!pt.isCtxDependent || (pt.isCtxDependent && inContext)))

      if (fullCtx)
        # In full context mode, we can evaluate predicates on-the-fly
        # during closure, which dramatically reduces the size of
        # the config sets. It also obviates the need to test predicates
        # later during conflict resolution.
        currentPosition = @_input.index()
        @_input.seek(@_startIndex)
        predSucceeds = evalSemanticContext(pt.getPredicate(), @_outerContext, config.alt, fullCtx)
        @_input.seek(currentPosition)
        if (predSucceeds)
          c = ATNConfig.new(config, pt.target) # no pred context
        end
      else
        newSemCtx = SemanticContext.and(config.semanticContext, pt.getPredicate())
        c = ATNConfig.new(config, pt.target, newSemCtx)
      end
    else
      c = ATNConfig.new(config, pt.target)
    end

    if (debug)
      puts("config from pred transition=" + c)
    end
    return c
  end


  def ruleTransition(config, t)
    if (@debug)
      puts("CALL rule " + getRuleName(t.target.ruleIndex) +
               ", ctx=" + config.context)
    end

    returnState = t.followState
    newContext = SingletonPredictionContext.create(config.context, returnState.stateNumber)
    return ATNConfig.new(config, t.target, newContext)
  end


  def getConflictingAlts(configs)
    altsets = PredictionMode.getConflictingAltSubsets(configs)
    return PredictionMode.getAlts(altsets)
  end


  def getConflictingAltsOrUniqueAlt(configs)
    conflictingAlts = nil
    if (configs.uniqueAlt != ATN.INVALID_ALT_NUMBER)
      conflictingAlts = new BitSet()
      conflictingAlts.set(configs.uniqueAlt)
    else
      conflictingAlts = configs.conflictingAlts
    end
    return conflictingAlts
  end


  def getTokenName(t)
    if (t == Token::EOF)
      return "EOF"
    end

    vocabulary = @parser != nil ? @parser.getVocabulary() : VocabularyImpl.EMPTY_VOCABULARY
    displayName = vocabulary.getDisplayName(t)
    if (displayName.equals(t.to_s))
      return displayName
    end

    return displayName + "<" + t + ">"
  end

  def getLookaheadName(input)
    return getTokenName(input.LA(1))
  end


  def dumpDeadEndConfigs(nvae)
    STDERR.puts("dead end configs: ")
    nvae.getDeadEndConfigs().each do |c|
      trans = "no edges"
      if (c.state.getNumberOfTransitions() > 0)
        t = c.state.transition(0)
        if (t.is_a? AtomTransition)
          at = t
          trans = "Atom " + getTokenName(at.label)
        elsif (t.is_a? SetTransition)
          st = t
          nott = st.is_a? NotSetTransition
          trans = (nott ? "~" : "") + "Set " + st.set.to_s()
        end
      end
      STDERR.puts(c.to_s(@parser, true) + ":" + trans)
    end
  end

  def self.getUniqueAlt(configs)
    alt = ATN.INVALID_ALT_NUMBER
    configs.each do |c|
      if (alt == ATN.INVALID_ALT_NUMBER)
        alt = c.alt # found first alt
      elsif (c.alt != alt)
        return ATN.INVALID_ALT_NUMBER
      end
    end
    return alt
  end


  def addDFAEdge(dfa, from, t, to)

    if (@debug)
      puts("EDGE " + from + " -> " + to + " upon " + getTokenName(t))
    end

    if (to == nil)
      return nil
    end

    to = addDFAState(dfa, to) # used existing if possible not incoming
    if (from == nil || t < -1 || t > atn.maxTokenType)
      return to
    end

    if (from.edges == nil)
      from.edges = []
    end

    from.edges[t + 1] = to # connect

    if (@debug)
      puts("DFA=\n" + dfa.to_s(@parser != nil ? @parser.getVocabulary() : VocabularyImpl.EMPTY_VOCABULARY))
    end

    return to
  end


  def addDFAState(dfa, d)
    if (d == ERROR)
      return d
    end

    existing = dfa.states.get(d)
    if (existing != nil)
      return existing
    end

    d.stateNumber = dfa.states.size()
    if (!d.configs.isReadonly())
      d.configs.optimizeConfigs(self)
      d.configs.setReadonly(true)
    end
    dfa.states.put(d, d)
    if (@debug)
      puts("adding new DFA state: " + d)
    end
    return d
  end

  def reportAttemptingFullContext(dfa, conflictingAlts, configs, startIndex, stopIndex)
    if (@debug || @retry_debug)
      interval = Interval.of(startIndex, stopIndex)
      puts("reportAttemptingFullContext decision=" + dfa.decision + ":" + configs +
               ", input=" + @parser.getTokenStream().getText(interval))
    end
    if (@parser != nil)
      @parser.getErrorListenerDispatch().reportAttemptingFullContext(@parser, dfa, startIndex, stopIndex, conflictingAlts, configs)
    end
  end

  def reportContextSensitivity(dfa, prediction, configs, startIndex, stopIndex)
    if (@debug || @retry_debug)
      interval = Interval.of(startIndex, stopIndex)
      puts("reportContextSensitivity decision=" + dfa.decision + ":" + configs +
               ", input=" + @parser.getTokenStream().getText(interval))
    end
    if (@parser != nil)
      @parser.getErrorListenerDispatch().reportContextSensitivity(@parser, dfa, startIndex, stopIndex, prediction, configs)
    end

  end


  def reportAmbiguity(dfa, d, startIndex, stopIndex, exact, ambigAlts, configs) # configs that LL not SLL considered conflicting

    if (@debug || @retry_debug)
      interval = Interval.of(startIndex, stopIndex)
      puts("reportAmbiguity " +
               ambigAlts + ":" + configs +
               ", input=" + @parser.getTokenStream().getText(interval))
    end
    if (@parser != nil)
      @parser.getErrorListenerDispatch().reportAmbiguity(@parser, dfa, startIndex, stopIndex,
                                                         exact, ambigAlts, configs)
    end
  end

  def setPredictionMode(mode)
    @mode = mode
  end


  def getPredictionMode()
    return @mode
  end


  def getParser()
    return @parser
  end

end
