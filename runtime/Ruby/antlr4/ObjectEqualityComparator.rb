












public final class ObjectEqualityComparator extends AbstractEqualityComparator<Object> 
	public static final ObjectEqualityComparator INSTANCE = new ObjectEqualityComparator()







	
	public int hashCode(Object obj) 
		if (obj == null) 
			return 0
		end

		return obj.hashCode()
	end










	
	public boolean equals(Object a, Object b) 
		if (a == null) 
			return b == null
		end

		return a.equals(b)
	end

end
