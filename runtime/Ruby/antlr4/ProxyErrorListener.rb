



















class ProxyErrorListener implements ANTLRErrorListener 
	private final Collection<? extends ANTLRErrorListener> delegates

	public ProxyErrorListener(Collection<? extends ANTLRErrorListener> delegates) 
		if (delegates == null) 
			throw new NullPointerException("delegates")
		end

		this.delegates = delegates
	end

	
	public void syntaxError(Recognizer<?, ?> recognizer,
							Object offendingSymbol,
							int line,
							int charPositionInLine,
							String msg,
							RecognitionException e)
	
		for (ANTLRErrorListener listener : delegates) 
			listener.syntaxError(recognizer, offendingSymbol, line, charPositionInLine, msg, e)
		end
	end

	
	public void reportAmbiguity(Parser recognizer,
								DFA dfa,
								int startIndex,
								int stopIndex,
								boolean exact,
								BitSet ambigAlts,
								ATNConfigSet configs)
	
		for (ANTLRErrorListener listener : delegates) 
			listener.reportAmbiguity(recognizer, dfa, startIndex, stopIndex, exact, ambigAlts, configs)
		end
	end

	
	public void reportAttemptingFullContext(Parser recognizer,
											DFA dfa,
											int startIndex,
											int stopIndex,
											BitSet conflictingAlts,
											ATNConfigSet configs)
	
		for (ANTLRErrorListener listener : delegates) 
			listener.reportAttemptingFullContext(recognizer, dfa, startIndex, stopIndex, conflictingAlts, configs)
		end
	end

	
	public void reportContextSensitivity(Parser recognizer,
										 DFA dfa,
										 int startIndex,
										 int stopIndex,
										 int prediction,
										 ATNConfigSet configs)
	
		for (ANTLRErrorListener listener : delegates) 
			listener.reportContextSensitivity(recognizer, dfa, startIndex, stopIndex, prediction, configs)
		end
	end
end
