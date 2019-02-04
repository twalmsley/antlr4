



































class DiagnosticErrorListener extends BaseErrorListener 



	protected final boolean exactOnly





	public DiagnosticErrorListener() 
		this(true)
	end








	public DiagnosticErrorListener(boolean exactOnly) 
		this.exactOnly = exactOnly
	end

	
	public void reportAmbiguity(Parser recognizer,
								DFA dfa,
								int startIndex,
								int stopIndex,
								boolean exact,
								BitSet ambigAlts,
								ATNConfigSet configs)
	
		if (exactOnly && !exact) 
			return
		end

		String format = "reportAmbiguity d=%s: ambigAlts=%s, input='%s'"
		String decision = getDecisionDescription(recognizer, dfa)
		BitSet conflictingAlts = getConflictingAlts(ambigAlts, configs)
		String text = recognizer.getTokenStream().getText(Interval.of(startIndex, stopIndex))
		String message = String.format(format, decision, conflictingAlts, text)
		recognizer.notifyErrorListeners(message)
	end

	
	public void reportAttemptingFullContext(Parser recognizer,
											DFA dfa,
											int startIndex,
											int stopIndex,
											BitSet conflictingAlts,
											ATNConfigSet configs)
	
		String format = "reportAttemptingFullContext d=%s, input='%s'"
		String decision = getDecisionDescription(recognizer, dfa)
		String text = recognizer.getTokenStream().getText(Interval.of(startIndex, stopIndex))
		String message = String.format(format, decision, text)
		recognizer.notifyErrorListeners(message)
	end

	
	public void reportContextSensitivity(Parser recognizer,
										 DFA dfa,
										 int startIndex,
										 int stopIndex,
										 int prediction,
										 ATNConfigSet configs)
	
		String format = "reportContextSensitivity d=%s, input='%s'"
		String decision = getDecisionDescription(recognizer, dfa)
		String text = recognizer.getTokenStream().getText(Interval.of(startIndex, stopIndex))
		String message = String.format(format, decision, text)
		recognizer.notifyErrorListeners(message)
	end

	protected String getDecisionDescription(Parser recognizer, DFA dfa) 
		int decision = dfa.decision
		int ruleIndex = dfa.atnStartState.ruleIndex

		String[] ruleNames = recognizer.getRuleNames()
		if (ruleIndex < 0 || ruleIndex >= ruleNames.length) 
			return String.valueOf(decision)
		end

		String ruleName = ruleNames[ruleIndex]
		if (ruleName == null || ruleName.isEmpty()) 
			return String.valueOf(decision)
		end

		return String.format("%d (%s)", decision, ruleName)
	end












	protected BitSet getConflictingAlts(BitSet reportedAlts, ATNConfigSet configs) 
		if (reportedAlts != null) 
			return reportedAlts
		end

		BitSet result = new BitSet()
		for (ATNConfig config : configs) 
			result.set(config.alt)
		end

		return result
	end
end
