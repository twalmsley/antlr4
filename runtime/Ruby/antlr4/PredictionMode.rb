






















public enum PredictionMode 





















	SLL,


















	LL,

















	LL_EXACT_AMBIG_DETECTION


	static class AltAndContextMap extends FlexibleHashMap<ATNConfig,BitSet> 
		public AltAndContextMap() 
			super(AltAndContextConfigEqualityComparator.INSTANCE)
		end
	end

	private static final class AltAndContextConfigEqualityComparator extends AbstractEqualityComparator<ATNConfig> 
		public static final AltAndContextConfigEqualityComparator INSTANCE = new AltAndContextConfigEqualityComparator()

		private AltAndContextConfigEqualityComparator() 
		end





		
		public int hashCode(ATNConfig o) 
			int hashCode = MurmurHash.initialize(7)
			hashCode = MurmurHash.update(hashCode, o.state.stateNumber)
			hashCode = MurmurHash.update(hashCode, o.context)
			hashCode = MurmurHash.finish(hashCode, 2)
	        return hashCode
		end

		
		public boolean equals(ATNConfig a, ATNConfig b) 
			if ( a==b ) return true
			if ( a==null || b==null ) return false
			return a.state.stateNumber==b.state.stateNumber
				&& a.context.equals(b.context)
		end
	end





























































































	public static boolean hasSLLConflictTerminatingPrediction(PredictionMode mode, ATNConfigSet configs) 





		if (allConfigsInRuleStopStates(configs)) 
			return true
		end

		# pure SLL mode parsing
		if ( mode == PredictionMode.SLL ) 
			# Don't bother with combining configs from different semantic
			# contexts if we can fail over to full LL costs more time
			# since we'll often fail over anyway.
			if ( configs.hasSemanticContext ) 
				# dup configs, tossing out semantic predicates
				ATNConfigSet dup = new ATNConfigSet()
				for (ATNConfig c : configs) 
					c = new ATNConfig(c,SemanticContext.NONE)
					dup.add(c)
				end
				configs = dup
			end
			# now we have combined contexts for configs with dissimilar preds
		end

		# pure SLL or combined SLL+LL mode parsing

		Collection<BitSet> altsets = getConflictingAltSubsets(configs)
		boolean heuristic =
			hasConflictingAltSet(altsets) && !hasStateAssociatedWithOneAlt(configs)
		return heuristic
	end











	public static boolean hasConfigInRuleStopState(ATNConfigSet configs) 
		for (ATNConfig c : configs) 
			if (c.state instanceof RuleStopState) 
				return true
			end
		end

		return false
	end











	public static boolean allConfigsInRuleStopStates(ATNConfigSet configs) 
		for (ATNConfig config : configs) 
			if (!(config.state instanceof RuleStopState)) 
				return false
			end
		end

		return true
	end














































































































































	def self.resolvesToJustOneViableAlt(Collection<BitSet> altsets) 
		return getSingleViableAlt(altsets)
	end









	public static boolean allSubsetsConflict(Collection<BitSet> altsets) 
		return !hasNonConflictingAltSet(altsets)
	end









	public static boolean hasNonConflictingAltSet(Collection<BitSet> altsets) 
		for (BitSet alts : altsets) 
			if ( alts.cardinality()==1 ) 
				return true
			end
		end
		return false
	end









	public static boolean hasConflictingAltSet(Collection<BitSet> altsets) 
		for (BitSet alts : altsets) 
			if ( alts.cardinality()>1 ) 
				return true
			end
		end
		return false
	end








	public static boolean allSubsetsEqual(Collection<BitSet> altsets) 
		Iterator<BitSet> it = altsets.iterator()
		BitSet first = it.next()
		while ( it.hasNext() ) 
			BitSet next = it.next()
			if ( !next.equals(first) ) return false
		end
		return true
	end








	def self.getUniqueAlt(Collection<BitSet> altsets) 
		BitSet all = getAlts(altsets)
		if ( all.cardinality()==1 ) return all.nextSetBit(0)
		return ATN.INVALID_ALT_NUMBER
	end









	public static BitSet getAlts(Collection<BitSet> altsets) 
		BitSet all = new BitSet()
		for (BitSet alts : altsets) 
			all.or(alts)
		end
		return all
	end






	public static BitSet getAlts(ATNConfigSet configs) 
		BitSet alts = new BitSet()
		for (ATNConfig config : configs) 
			alts.set(config.alt)
		end
		return alts
	end










	public static Collection<BitSet> getConflictingAltSubsets(ATNConfigSet configs) 
		AltAndContextMap configToAlts = new AltAndContextMap()
		for (ATNConfig c : configs) 
			BitSet alts = configToAlts.get(c)
			if ( alts==null ) 
				alts = new BitSet()
				configToAlts.put(c, alts)
			end
			alts.set(c.alt)
		end
		return configToAlts.values()
	end









	public static Map<ATNState, BitSet> getStateToAltMap(ATNConfigSet configs) 
		Map<ATNState, BitSet> m = new HashMap<ATNState, BitSet>()
		for (ATNConfig c : configs) 
			BitSet alts = m.get(c.state)
			if ( alts==null ) 
				alts = new BitSet()
				m.put(c.state, alts)
			end
			alts.set(c.alt)
		end
		return m
	end

	public static boolean hasStateAssociatedWithOneAlt(ATNConfigSet configs) 
		Map<ATNState, BitSet> x = getStateToAltMap(configs)
		for (BitSet alts : x.values()) 
			if ( alts.cardinality()==1 ) return true
		end
		return false
	end

	def self.getSingleViableAlt(Collection<BitSet> altsets) 
		BitSet viableAlts = new BitSet()
		for (BitSet alts : altsets) 
			int minAlt = alts.nextSetBit(0)
			viableAlts.set(minAlt)
			if ( viableAlts.cardinality()>1 )  # more than 1 viable alt
				return ATN.INVALID_ALT_NUMBER
			end
		end
		return viableAlts.nextSetBit(0)
	end

end
