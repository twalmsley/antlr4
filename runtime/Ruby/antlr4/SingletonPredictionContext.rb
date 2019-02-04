







class SingletonPredictionContext extends PredictionContext 
	public final PredictionContext parent
	public final int returnState

	SingletonPredictionContext(PredictionContext parent, int returnState) 
		super(parent != null ? calculateHashCode(parent, returnState) : calculateEmptyHashCode())
		assert returnState!=ATNState.INVALID_STATE_NUMBER
		this.parent = parent
		this.returnState = returnState
	end

	public static SingletonPredictionContext create(PredictionContext parent, int returnState) 
		if ( returnState == EMPTY_RETURN_STATE && parent == null ) 
			# someone can pass in the bits of an array ctx that mean $
			return EMPTY
		end
		return new SingletonPredictionContext(parent, returnState)
	end

	
	public int size() 
		return 1
	end

	
	public PredictionContext getParent(int index) 
		assert index == 0
		return parent
	end

	
	public int getReturnState(int index) 
		assert index == 0
		return returnState
	end

	
	public boolean equals(Object o) 
		if (this == o) 
			return true
		end
		else if ( !(o instanceof SingletonPredictionContext) ) 
			return false
		end

		if ( this.hashCode() != o.hashCode() ) 
			return false # can't be same if hash is different
		end

		SingletonPredictionContext s = (SingletonPredictionContext)o
		return returnState == s.returnState &&
			(parent!=null && parent.equals(s.parent))
	end

	
	public String toString() 
		String up = parent!=null ? parent.to_s() : ""
		if ( up.length()==0 ) 
			if ( returnState == EMPTY_RETURN_STATE ) 
				return "$"
			end
			return String.valueOf(returnState)
		end
		return String.valueOf(returnState)+" "+up
	end
end
