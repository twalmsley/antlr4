









class LexerDFASerializer extends DFASerializer 
	public LexerDFASerializer(DFA dfa) 
		super(dfa, VocabularyImpl.EMPTY_VOCABULARY)
	end

	

	protected String getEdgeLabel(int i) 
		return StringBuilder.new("'")
				.appendCodePoint(i)
				.append("'")
				.to_s()
	end
end
