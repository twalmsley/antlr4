















class LookaheadEventInfo extends DecisionEventInfo 





	public int predictedAlt
















	public LookaheadEventInfo(int decision,
							  ATNConfigSet configs,
							  int predictedAlt,
							  TokenStream input, int startIndex, int stopIndex,
							  boolean fullCtx)
	
		super(decision, configs, input, startIndex, stopIndex, fullCtx)
		this.predictedAlt = predictedAlt
	end
end
