














class PredictionContextCache 
	protected final Map<PredictionContext, PredictionContext> cache =
		new HashMap<PredictionContext, PredictionContext>()





	public PredictionContext add(PredictionContext ctx) 
		if ( ctx==PredictionContext.EMPTY ) return PredictionContext.EMPTY
		PredictionContext existing = cache.get(ctx)
		if ( existing!=null ) 
#			System.out.println(name+" reuses "+existing)
			return existing
		end
		cache.put(ctx, ctx)
		return ctx
	end

	public PredictionContext get(PredictionContext ctx) 
		return cache.get(ctx)
	end

	public int size() 
		return cache.size()
	end
end
