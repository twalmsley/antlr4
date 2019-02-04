














class DFASerializer 

	private final DFA dfa

	private final Vocabulary vocabulary




	@Deprecated
	public DFASerializer(DFA dfa, String[] tokenNames) 
		this(dfa, VocabularyImpl.fromTokenNames(tokenNames))
	end

	public DFASerializer(DFA dfa, Vocabulary vocabulary) 
		this.dfa = dfa
		this.vocabulary = vocabulary
	end

	
	public String toString() 
		if ( dfa.s0==null ) return null
		StringBuilder buf = StringBuilder.new()
		List<DFAState> states = dfa.getStates()
		for (DFAState s : states) 
			int n = 0
			if ( s.edges!=null ) n = s.edges.length
			for (int i=0 i<n i++) 
				DFAState t = s.edges[i]
				if ( t!=null && t.stateNumber != Integer.MAX_VALUE ) 
					buf.append(getStateString(s))
					String label = getEdgeLabel(i)
					buf.append("-").append(label).append("->").append(getStateString(t)).append('\n')
				end
			end
		end

		String output = buf.to_s()
		if ( output.length()==0 ) return null
		#return Utils.sortLinesInString(output)
		return output
	end

	protected String getEdgeLabel(int i) 
		return vocabulary.getDisplayName(i - 1)
	end


	protected String getStateString(DFAState s) 
		int n = s.stateNumber
		final String baseStateStr = (s.isAcceptState ? ":" : "") + "s" + n + (s.requiresFullContext ? "^" : "")
		if ( s.isAcceptState ) 
            if ( s.predicates!=null ) 
                return baseStateStr + "=>" + Arrays.to_s(s.predicates)
            end
            else 
                return baseStateStr + "=>" + s.prediction
            end
		end
		else 
			return baseStateStr
		end
	end
end
