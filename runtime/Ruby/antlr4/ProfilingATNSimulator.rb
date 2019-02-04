


















class ProfilingATNSimulator extends ParserATNSimulator 
	protected final DecisionInfo[] decisions
	protected int numDecisions

	protected int _sllStopIndex
	protected int _llStopIndex

	protected int currentDecision
	protected DFAState currentState












	protected int conflictingAltResolvedBySLL

	public ProfilingATNSimulator(Parser parser) 
		super(parser,
				parser.getInterpreter().atn,
				parser.getInterpreter().decisionToDFA,
				parser.getInterpreter().sharedContextCache)
		numDecisions = atn.decisionToState.size()
		decisions = new DecisionInfo[numDecisions]
		for (int i=0 i<numDecisions i++) 
			decisions[i] = new DecisionInfo(i)
		end
	end

	
	public int adaptivePredict(TokenStream input, int decision, ParserRuleContext outerContext) 
		try 
			this._sllStopIndex = -1
			this._llStopIndex = -1
			this.currentDecision = decision
			long start = System.nanoTime() # expensive but useful info
			int alt = super.adaptivePredict(input, decision, outerContext)
			long stop = System.nanoTime()
			decisions[decision].timeInPrediction += (stop-start)
			decisions[decision].invocations++

			int SLL_k = _sllStopIndex - _startIndex + 1
			decisions[decision].SLL_TotalLook += SLL_k
			decisions[decision].SLL_MinLook = decisions[decision].SLL_MinLook==0 ? SLL_k : Math.min(decisions[decision].SLL_MinLook, SLL_k)
			if ( SLL_k > decisions[decision].SLL_MaxLook ) 
				decisions[decision].SLL_MaxLook = SLL_k
				decisions[decision].SLL_MaxLookEvent =
						new LookaheadEventInfo(decision, null, alt, input, _startIndex, _sllStopIndex, false)
			end

			if (_llStopIndex >= 0) 
				int LL_k = _llStopIndex - _startIndex + 1
				decisions[decision].LL_TotalLook += LL_k
				decisions[decision].LL_MinLook = decisions[decision].LL_MinLook==0 ? LL_k : Math.min(decisions[decision].LL_MinLook, LL_k)
				if ( LL_k > decisions[decision].LL_MaxLook ) 
					decisions[decision].LL_MaxLook = LL_k
					decisions[decision].LL_MaxLookEvent =
							new LookaheadEventInfo(decision, null, alt, input, _startIndex, _llStopIndex, true)
				end
			end

			return alt
		end
		finally 
			this.currentDecision = -1
		end
	end

	
	protected DFAState getExistingTargetState(DFAState previousD, int t) 
		# this method is called after each time the input position advances
		# during SLL prediction
		_sllStopIndex = _input.index()

		DFAState existingTargetState = super.getExistingTargetState(previousD, t)
		if ( existingTargetState!=null ) 
			decisions[currentDecision].SLL_DFATransitions++ # count only if we transition over a DFA state
			if ( existingTargetState==ERROR ) 
				decisions[currentDecision].errors.add(
						new ErrorInfo(currentDecision, previousD.configs, _input, _startIndex, _sllStopIndex, false)
				)
			end
		end

		currentState = existingTargetState
		return existingTargetState
	end

	
	protected DFAState computeTargetState(DFA dfa, DFAState previousD, int t) 
		DFAState state = super.computeTargetState(dfa, previousD, t)
		currentState = state
		return state
	end

	
	protected ATNConfigSet computeReachSet(ATNConfigSet closure, int t, boolean fullCtx) 
		if (fullCtx) 
			# this method is called after each time the input position advances
			# during full context prediction
			_llStopIndex = _input.index()
		end

		ATNConfigSet reachConfigs = super.computeReachSet(closure, t, fullCtx)
		if (fullCtx) 
			decisions[currentDecision].LL_ATNTransitions++ # count computation even if error
			if ( reachConfigs!=null ) 
			end
			else  # no reach on current lookahead symbol. ERROR.
				# TODO: does not handle delayed errors per getSynValidOrSemInvalidAltThatFinishedDecisionEntryRule()
				decisions[currentDecision].errors.add(
					new ErrorInfo(currentDecision, closure, _input, _startIndex, _llStopIndex, true)
				)
			end
		end
		else 
			decisions[currentDecision].SLL_ATNTransitions++
			if ( reachConfigs!=null ) 
			end
			else  # no reach on current lookahead symbol. ERROR.
				decisions[currentDecision].errors.add(
					new ErrorInfo(currentDecision, closure, _input, _startIndex, _sllStopIndex, false)
				)
			end
		end
		return reachConfigs
	end

	
	protected boolean evalSemanticContext(SemanticContext pred, ParserRuleContext parserCallStack, int alt, boolean fullCtx) 
		boolean result = super.evalSemanticContext(pred, parserCallStack, alt, fullCtx)
		if (!(pred instanceof SemanticContext.PrecedencePredicate)) 
			boolean fullContext = _llStopIndex >= 0
			int stopIndex = fullContext ? _llStopIndex : _sllStopIndex
			decisions[currentDecision].predicateEvals.add(
				new PredicateEvalInfo(currentDecision, _input, _startIndex, stopIndex, pred, result, alt, fullCtx)
			)
		end

		return result
	end

	
	protected void reportAttemptingFullContext(DFA dfa, BitSet conflictingAlts, ATNConfigSet configs, int startIndex, int stopIndex) 
		if ( conflictingAlts!=null ) 
			conflictingAltResolvedBySLL = conflictingAlts.nextSetBit(0)
		end
		else 
			conflictingAltResolvedBySLL = configs.getAlts().nextSetBit(0)
		end
		decisions[currentDecision].LL_Fallback++
		super.reportAttemptingFullContext(dfa, conflictingAlts, configs, startIndex, stopIndex)
	end

	
	protected void reportContextSensitivity(DFA dfa, int prediction, ATNConfigSet configs, int startIndex, int stopIndex) 
		if ( prediction != conflictingAltResolvedBySLL ) 
			decisions[currentDecision].contextSensitivities.add(
					new ContextSensitivityInfo(currentDecision, configs, _input, startIndex, stopIndex)
			)
		end
		super.reportContextSensitivity(dfa, prediction, configs, startIndex, stopIndex)
	end

	
	protected void reportAmbiguity(DFA dfa, DFAState D, int startIndex, int stopIndex, boolean exact,
								   BitSet ambigAlts, ATNConfigSet configs)
	
		int prediction
		if ( ambigAlts!=null ) 
			prediction = ambigAlts.nextSetBit(0)
		end
		else 
			prediction = configs.getAlts().nextSetBit(0)
		end
		if ( configs.fullCtx && prediction != conflictingAltResolvedBySLL ) 
			# Even though this is an ambiguity we are reporting, we can
			# still detect some context sensitivities.  Both SLL and LL
			# are showing a conflict, hence an ambiguity, but if they resolve
			# to different minimum alternatives we have also identified a
			# context sensitivity.
			decisions[currentDecision].contextSensitivities.add(
					new ContextSensitivityInfo(currentDecision, configs, _input, startIndex, stopIndex)
			)
		end
		decisions[currentDecision].ambiguities.add(
			new AmbiguityInfo(currentDecision, configs, ambigAlts,
							  _input, startIndex, stopIndex, configs.fullCtx)
		)
		super.reportAmbiguity(dfa, D, startIndex, stopIndex, exact, ambigAlts, configs)
	end

	# ---------------------------------------------------------------------

	public DecisionInfo[] getDecisionInfo() 
		return decisions
	end

	public DFAState getCurrentState() 
		return currentState
	end
end
