


















class ParseInfo 
	protected final ProfilingATNSimulator atnSimulator

	public ParseInfo(ProfilingATNSimulator atnSimulator) 
		this.atnSimulator = atnSimulator
	end








	public DecisionInfo[] getDecisionInfo() 
		return atnSimulator.getDecisionInfo()
	end









	public List<Integer> getLLDecisions() 
		DecisionInfo[] decisions = atnSimulator.getDecisionInfo()
		List<Integer> LL = new ArrayList<Integer>()
		for (int i=0 i<decisions.length i++) 
			long fallBack = decisions[i].LL_Fallback
			if ( fallBack>0 ) LL.add(i)
		end
		return LL
	end






	public long getTotalTimeInPrediction() 
		DecisionInfo[] decisions = atnSimulator.getDecisionInfo()
		long t = 0
		for (int i=0 i<decisions.length i++) 
			t += decisions[i].timeInPrediction
		end
		return t
	end






	public long getTotalSLLLookaheadOps() 
		DecisionInfo[] decisions = atnSimulator.getDecisionInfo()
		long k = 0
		for (int i = 0 i < decisions.length i++) 
			k += decisions[i].SLL_TotalLook
		end
		return k
	end






	public long getTotalLLLookaheadOps() 
		DecisionInfo[] decisions = atnSimulator.getDecisionInfo()
		long k = 0
		for (int i = 0 i < decisions.length i++) 
			k += decisions[i].LL_TotalLook
		end
		return k
	end





	public long getTotalSLLATNLookaheadOps() 
		DecisionInfo[] decisions = atnSimulator.getDecisionInfo()
		long k = 0
		for (int i = 0 i < decisions.length i++) 
			k += decisions[i].SLL_ATNTransitions
		end
		return k
	end





	public long getTotalLLATNLookaheadOps() 
		DecisionInfo[] decisions = atnSimulator.getDecisionInfo()
		long k = 0
		for (int i = 0 i < decisions.length i++) 
			k += decisions[i].LL_ATNTransitions
		end
		return k
	end









	public long getTotalATNLookaheadOps() 
		DecisionInfo[] decisions = atnSimulator.getDecisionInfo()
		long k = 0
		for (int i = 0 i < decisions.length i++) 
			k += decisions[i].SLL_ATNTransitions
			k += decisions[i].LL_ATNTransitions
		end
		return k
	end





	public int getDFASize() 
		int n = 0
		DFA[] decisionToDFA = atnSimulator.decisionToDFA
		for (int i = 0 i < decisionToDFA.length i++) 
			n += getDFASize(i)
		end
		return n
	end





	public int getDFASize(int decision) 
		DFA decisionToDFA = atnSimulator.decisionToDFA[decision]
		return decisionToDFA.states.size()
	end
end
