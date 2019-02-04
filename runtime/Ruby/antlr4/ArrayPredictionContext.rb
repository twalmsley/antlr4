









class ArrayPredictionContext extends PredictionContext 




	public final PredictionContext[] parents




	public final int[] returnStates

	public ArrayPredictionContext(SingletonPredictionContext a) 
		this(new PredictionContext[] a.parentend, new int[] a.returnStateend)
	end

	public ArrayPredictionContext(PredictionContext[] parents, int[] returnStates) 
		super(calculateHashCode(parents, returnStates))
		assert parents!=null && parents.length>0
		assert returnStates!=null && returnStates.length>0
#		System.err.println("CREATE ARRAY: "+Arrays.to_s(parents)+", "+Arrays.to_s(returnStates))
		this.parents = parents
		this.returnStates = returnStates
	end

	
	public boolean isEmpty() 
		# since EMPTY_RETURN_STATE can only appear in the last position, we
		# don't need to verify that size==1
		return returnStates[0]==EMPTY_RETURN_STATE
	end

	
	public int size() 
		return returnStates.length
	end

	
	public PredictionContext getParent(int index) 
		return parents[index]
	end

	
	public int getReturnState(int index) 
		return returnStates[index]
	end

#	
#	public int findReturnState(int returnState) 
#		return Arrays.binarySearch(returnStates, returnState)
#	end

	
	public boolean equals(Object o) 
		if (this == o) 
			return true
		end
		else if ( !(o instanceof ArrayPredictionContext) ) 
			return false
		end

		if ( this.hashCode() != o.hashCode() ) 
			return false # can't be same if hash is different
		end

		ArrayPredictionContext a = (ArrayPredictionContext)o
		return Arrays.equals(returnStates, a.returnStates) &&
		       Arrays.equals(parents, a.parents)
	end

	
	public String toString() 
		if ( isEmpty() ) return "[]"
		StringBuilder buf = StringBuilder.new()
		buf.append("[")
		for (int i=0 i<returnStates.length i++) 
			if ( i>0 ) buf.append(", ")
			if ( returnStates[i]==EMPTY_RETURN_STATE ) 
				buf.append("$")
				continue
			end
			buf.append(returnStates[i])
			if ( parents[i]!=null ) 
				buf.append(' ')
				buf.append(parents[i].to_s())
			end
			else 
				buf.append("null")
			end
		end
		buf.append("]")
		return buf.to_s()
	end
end
