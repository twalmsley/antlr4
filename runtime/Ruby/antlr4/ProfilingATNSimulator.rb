class ProfilingATNSimulator < ParserATNSimulator

  def initialize(parser)
    super(parser,
          parser.getInterpreter().atn,
          parser.getInterpreter().decisionToDFA,
          parser.getInterpreter().sharedContextCache)

    @numDecisions = @atn.decisionToState.size()
    @_sllStopIndex = 0
    @_llStopIndex = 0
    @currentDecision = 0
    @currentState = nil
    @conflictingAltResolvedBySLL = 0

    @decisions = Array.new(numDecisions)
    i = 0
    while i < @numDecisions
      @decisions[i] = DecisionInfo.new(i)
      i += 1
    end
  end


  def adaptivePredict(input, decision, outerContext)
    begin
      @_sllStopIndex = -1
      @_llStopIndex = -1
      @currentDecision = decision
      start = Time.now # expensive but useful info
      alt = super.adaptivePredict(input, decision, outerContext)
      stop = Time.now
      @decisions[decision].timeInPrediction += (stop - start)
      @decisions[decision].invocations += 1

      _S_LL_k = @_sllStopIndex - @_startIndex + 1
      @decisions[decision].SLL_TotalLook += _S_LL_k
      @decisions[decision].SLL_MinLook = @decisions[decision].SLL_MinLook == 0 ? _S_LL_k : Math.min(@decisions[decision].SLL_MinLook, _S_LL_k)
      if (_S_LL_k > @decisions[decision].SLL_MaxLook)
        @decisions[decision].SLL_MaxLook = _S_LL_k
        @decisions[decision].SLL_MaxLookEvent =
            LookaheadEventInfo.new(decision, nil, alt, input, @_startIndex, @_sllStopIndex, false)
      end

      if (@_llStopIndex >= 0)
        _LL_k = @_llStopIndex - @_startIndex + 1
        @decisions[decision].LL_TotalLook += _LL_k
        @decisions[decision].LL_MinLook = @decisions[decision].LL_MinLook == 0 ? _LL_k : Math.min(@decisions[decision].LL_MinLook, _LL_k)
        if (_LL_k > @decisions[decision].LL_MaxLook)
          @decisions[decision].LL_MaxLook = _LL_k
          @decisions[decision].LL_MaxLookEvent =
              LookaheadEventInfo.new(decision, nil, alt, input, @_startIndex, @_llStopIndex, true)
        end
      end

      return alt
    ensure
      @currentDecision = -1
    end
  end


  def getExistingTargetState(previousD, t)
# this method is called after each time the input position advances
# during SLL prediction
    @_sllStopIndex = @_input.index()

    existingTargetState = super.getExistingTargetState(previousD, t)
    if (existingTargetState != nil)
      @decisions[@currentDecision].SLL_DFATransitions += 1 # count only if we transition over a DFA state
      if (existingTargetState == ERROR)
        @decisions[@currentDecision].errors.add(
            ErrorInfo.new(@currentDecision, previousD.configs, @_input, @_startIndex, @_sllStopIndex, false)
        )
      end
    end

    @currentState = existingTargetState
    return existingTargetState
  end


  def computeTargetState(dfa, previousD, t)
    state = super.computeTargetState(dfa, previousD, t)
    @currentState = state
    return state
  end


  def computeReachSet(closure, t, fullCtx)
    if (fullCtx)
      # this method is called after each time the input position advances
      # during full context prediction
      @_llStopIndex = @_input.index()
    end

    reachConfigs = super.computeReachSet(closure, t, fullCtx)
    if (fullCtx)
      @decisions[@currentDecision].LL_ATNTransitions += 1 # count computation even if error
      if (reachConfigs != nil)
      else # no reach on current lookahead symbol. ERROR.
        # TODO: does not handle delayed errors per getSynValidOrSemInvalidAltThatFinishedDecisionEntryRule()
        @decisions[@currentDecision].errors.add(
            ErrorInfo.new(@currentDecision, closure, @_input, @_startIndex, @_llStopIndex, true)
        )
      end
    else
      @decisions[@currentDecision].SLL_ATNTransitions += 1
      if (reachConfigs != nil)
      else # no reach on current lookahead symbol. ERROR.
        @decisions[@currentDecision].errors.add(
            ErrorInfo.new(@currentDecision, closure, @_input, @_startIndex, @_sllStopIndex, false)
        )
      end
    end

    return reachConfigs
  end


  def evalSemanticContext(pred, parserCallStack, alt, fullCtx)
    result = super.evalSemanticContext(pred, parserCallStack, alt, fullCtx)
    if (!(pred.is_a? SemanticContext.PrecedencePredicate))
      fullContext = (@_llStopIndex >= 0)
      stopIndex = fullContext ? @_llStopIndex : @_sllStopIndex
      @decisions[@currentDecision].predicateEvals.add(
          PredicateEvalInfo.new(@currentDecision, @_input, @_startIndex, stopIndex, pred, result, alt, fullCtx)
      )
    end

    return result
  end


  def reportAttemptingFullContext(dfa, conflictingAlts, configs, startIndex, stopIndex)
    if (conflictingAlts != nil)
      @conflictingAltResolvedBySLL = conflictingAlts.nextSetBit(0)
    else
      conflictingAltResolvedBySLL = configs.getAlts().nextSetBit(0)
    end
    @decisions[@currentDecision].LL_Fallback += 1
    super.reportAttemptingFullContext(dfa, conflictingAlts, configs, startIndex, stopIndex)
  end


  def reportContextSensitivity(dfa, prediction, configs, startIndex, stopIndex)
    if (prediction != conflictingAltResolvedBySLL)
      @decisions[@currentDecision].contextSensitivities.add(
          ContextSensitivityInfo.new(@currentDecision, configs, @_input, startIndex, stopIndex)
      )
    end
    super.reportContextSensitivity(dfa, prediction, configs, startIndex, stopIndex)
  end


  def reportAmbiguity(dfa, _d, startIndex, stopIndex, exact, ambigAlts, configs)

    prediction = 0
    if (ambigAlts != nil)
      prediction = ambigAlts.nextSetBit(0)
    else
      prediction = configs.getAlts().nextSetBit(0)
    end

    if (configs.fullCtx && prediction != @conflictingAltResolvedBySLL)
      # Even though this is an ambiguity we are reporting, we can
      # still detect some context sensitivities.  Both SLL and LL
      # are showing a conflict, hence an ambiguity, but if they resolve
      # to different minimum alternatives we have also identified a
      # context sensitivity.
      @decisions[@currentDecision].contextSensitivities.add(
          ContextSensitivityInfo.new(@currentDecision, configs, @_input, startIndex, stopIndex)
      )
    end
    @decisions[@currentDecision].ambiguities.add(
        AmbiguityInfo.new(@currentDecision, configs, ambigAlts,
                          @_input, startIndex, stopIndex, configs.fullCtx)
    )
    super.reportAmbiguity(dfa, _d, startIndex, stopIndex, exact, ambigAlts, configs)
  end

# ---------------------------------------------------------------------

  def getDecisionInfo()
    return @decisions
  end

  def getCurrentState()
    return @currentState
  end
end
