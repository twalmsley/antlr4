























class DecisionInfo 



	public final int decision





	public long invocations















	public long timeInPrediction







	public long SLL_TotalLook






	public long SLL_MinLook






	public long SLL_MaxLook





	public LookaheadEventInfo SLL_MaxLookEvent






	public long LL_TotalLook








	public long LL_MinLook








	public long LL_MaxLook





	public LookaheadEventInfo LL_MaxLookEvent







	public final List<ContextSensitivityInfo> contextSensitivities = new ArrayList<ContextSensitivityInfo>()








	public final List<ErrorInfo> errors = new ArrayList<ErrorInfo>()







	public final List<AmbiguityInfo> ambiguities = new ArrayList<AmbiguityInfo>()








	public final List<PredicateEvalInfo> predicateEvals = new ArrayList<PredicateEvalInfo>()

















	public long SLL_ATNTransitions











	public long SLL_DFATransitions












	public long LL_Fallback

















	public long LL_ATNTransitions











	public long LL_DFATransitions







	public DecisionInfo(int decision) 
		this.decision = decision
	end

	
	public String toString() 
		return "" +
			   "decision=" + decision +
			   ", contextSensitivities=" + contextSensitivities.size() +
			   ", errors=" + errors.size() +
			   ", ambiguities=" + ambiguities.size() +
			   ", SLL_lookahead=" + SLL_TotalLook +
			   ", SLL_ATNTransitions=" + SLL_ATNTransitions +
			   ", SLL_DFATransitions=" + SLL_DFATransitions +
			   ", LL_Fallback=" + LL_Fallback +
			   ", LL_lookahead=" + LL_TotalLook +
			   ", LL_ATNTransitions=" + LL_ATNTransitions +
			   'end'
	end
end
