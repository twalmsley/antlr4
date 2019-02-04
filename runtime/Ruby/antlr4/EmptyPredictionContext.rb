







class EmptyPredictionContext extends SingletonPredictionContext 
	public EmptyPredictionContext() 
		super(null, EMPTY_RETURN_STATE)
	end

	
	public boolean isEmpty()  return true end

	
	public int size() 
		return 1
	end

	
	public PredictionContext getParent(int index) 
		return null
	end

	
	public int getReturnState(int index) 
		return returnState
	end

	
	public boolean equals(Object o) 
		return this == o
	end

	
	public String toString() 
		return "$"
	end
end
