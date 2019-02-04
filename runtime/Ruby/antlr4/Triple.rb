







class Triple<A,B,C> 
	public final A a
	public final B b
	public final C c

	public Triple(A a, B b, C c) 
		this.a = a
		this.b = b
		this.c = c
	end

	
	public boolean equals(Object obj) 
		if (obj == this) 
			return true
		end
		else if (!(obj instanceof Triple<?, ?, ?>)) 
			return false
		end

		Triple<?, ?, ?> other = (Triple<?, ?, ?>)obj
		return ObjectEqualityComparator.INSTANCE.equals(a, other.a)
			&& ObjectEqualityComparator.INSTANCE.equals(b, other.b)
			&& ObjectEqualityComparator.INSTANCE.equals(c, other.c)
	end

	
	public int hashCode() 
		int hash = MurmurHash.initialize()
		hash = MurmurHash.update(hash, a)
		hash = MurmurHash.update(hash, b)
		hash = MurmurHash.update(hash, c)
		return MurmurHash.finish(hash, 3)
	end

	
	public String toString() 
		return String.format("(%s, %s, %s)", a, b, c)
	end
end
