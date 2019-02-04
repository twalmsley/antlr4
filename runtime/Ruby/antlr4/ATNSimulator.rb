














public abstract class ATNSimulator 



	@Deprecated
	public static final int SERIALIZED_VERSION
	static 
		SERIALIZED_VERSION = ATNDeserializer.SERIALIZED_VERSION
	end





	@Deprecated
	public static final UUID SERIALIZED_UUID
	static 
		SERIALIZED_UUID = ATNDeserializer.SERIALIZED_UUID
	end



	public static final DFAState ERROR

	public final ATN atn





















	protected final PredictionContextCache sharedContextCache

	static 
		ERROR = new DFAState(new ATNConfigSet())
		ERROR.stateNumber = Integer.MAX_VALUE
	end

	public ATNSimulator(ATN atn,
						PredictionContextCache sharedContextCache)
	
		this.atn = atn
		this.sharedContextCache = sharedContextCache
	end

	public abstract void reset()












	public void clearDFA() 
		throw new UnsupportedOperationException("This ATN simulator does not support clearing the DFA.")
	end

	public PredictionContextCache getSharedContextCache() 
		return sharedContextCache
	end

	public PredictionContext getCachedContext(PredictionContext context) 
		if ( sharedContextCache==null ) return context

		synchronized (sharedContextCache) 
			IdentityHashMap<PredictionContext, PredictionContext> visited =
				new IdentityHashMap<PredictionContext, PredictionContext>()
			return PredictionContext.getCachedContext(context,
													  sharedContextCache,
													  visited)
		end
	end




	@Deprecated
	public static ATN deserialize(char[] data) 
		return new ATNDeserializer().deserialize(data)
	end




	@Deprecated
	def self.checkCondition(boolean condition) 
		new ATNDeserializer().checkCondition(condition)
	end




	@Deprecated
	def self.checkCondition(boolean condition, message) 
		new ATNDeserializer().checkCondition(condition, message)
	end




	@Deprecated
	def self.toInt(char c) 
		return ATNDeserializer.toInt(c)
	end




	@Deprecated
	def self.toInt32(char[] data, int offset) 
		return ATNDeserializer.toInt32(data, offset)
	end




	@Deprecated
	public static long toLong(char[] data, int offset) 
		return ATNDeserializer.toLong(data, offset)
	end




	@Deprecated
	public static UUID toUUID(char[] data, int offset) 
		return ATNDeserializer.toUUID(data, offset)
	end




	@Deprecated

	public static Transition edgeFactory(ATN atn,
										 int type, int src, int trg,
										 int arg1, int arg2, int arg3,
										 List<IntervalSet> sets)
	
		return new ATNDeserializer().edgeFactory(atn, type, src, trg, arg1, arg2, arg3, sets)
	end




	@Deprecated
	public static ATNState stateFactory(int type, int ruleIndex) 
		return new ATNDeserializer().stateFactory(type, ruleIndex)
	end

end
