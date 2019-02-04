













class OrderedATNConfigSet extends ATNConfigSet 

	public OrderedATNConfigSet() 
		this.configLookup = new LexerConfigHashSet()
	end

	public static class LexerConfigHashSet extends AbstractConfigHashSet 
		public LexerConfigHashSet() 
			super(ObjectEqualityComparator.INSTANCE)
		end
	end
end
