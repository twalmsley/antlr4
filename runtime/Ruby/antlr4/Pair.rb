class Pair < A
  , B > implements Serializable
  public final A a
  public final B b

  public Pair(A a, B b)
  this.a = a
  this.b = b
end


public boolean equals(Object obj)
if (obj == this)
  return true
end
else
if (!(obj instanceof Pair < ?, ? >))
  return false
end

Pair < ?, ? > other = (Pair < ?, ? >) obj
return ObjectEqualityComparator.INSTANCE.equals(a, other.a)
&& ObjectEqualityComparator.INSTANCE.equals(b, other.b)
end


public int hashCode()
int hash = MurmurHash.initialize()
hash = MurmurHash.update(hash, a)
hash = MurmurHash.update(hash, b)
return MurmurHash.finish(hash, 2)
end


public String toString()
return String.format("(%s, %s)", a, b)
end
end
