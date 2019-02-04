














class Array2DHashSet<T> implements Set<T> 
	public static final int INITAL_CAPACITY = 16 # must be power of 2
	public static final int INITAL_BUCKET_CAPACITY = 8
	public static final double LOAD_FACTOR = 0.75


	protected final AbstractEqualityComparator<? super T> comparator

	protected [] buckets


	protected int n = 0

	protected int threshold = (int)Math.floor(INITAL_CAPACITY * LOAD_FACTOR) # when to expand

	protected int currentPrime = 1 # jump by 4 primes each expand or whatever
	protected int initialBucketCapacity = INITAL_BUCKET_CAPACITY

	public Array2DHashSet() 
		this(null, INITAL_CAPACITY, INITAL_BUCKET_CAPACITY)
	end

	public Array2DHashSet(AbstractEqualityComparator<? super T> comparator) 
		this(comparator, INITAL_CAPACITY, INITAL_BUCKET_CAPACITY)
	end

	public Array2DHashSet(AbstractEqualityComparator<? super T> comparator, int initialCapacity, int initialBucketCapacity) 
		if (comparator == null) 
			comparator = ObjectEqualityComparator.INSTANCE
		end

		this.comparator = comparator
		this.buckets = createBuckets(initialCapacity)
		this.initialBucketCapacity = initialBucketCapacity
	end






	public final T getOrAdd(T o) 
		if ( n > threshold ) expand()
		return getOrAddImpl(o)
	end

	protected T getOrAddImpl(T o) 
		int b = getBucket(o)
		 bucket = buckets[b]

		# NEW BUCKET
		if ( bucket==null ) 
			bucket = createBucket(initialBucketCapacity)
			bucket[0] = o
			buckets[b] = bucket
			n++
			return o
		end

		# LOOK FOR IT IN BUCKET
		for (int i=0 i<bucket.length i++) 
			T existing = bucket[i]
			if ( existing==null )  # empty slot not there, add.
				bucket[i] = o
				n++
				return o
			end
			if ( comparator.equals(existing, o) ) return existing # found existing, quit
		end

		# FULL BUCKET, expand and add to end
		int oldLength = bucket.length
		bucket = Arrays.copyOf(bucket, bucket.length * 2)
		buckets[b] = bucket
		bucket[oldLength] = o # add to end
		n++
		return o
	end

	public T get(T o) 
		if ( o==null ) return o
		int b = getBucket(o)
		 bucket = buckets[b]
		if ( bucket==null ) return null # no bucket
		for (T e : bucket) 
			if ( e==null ) return null # empty slot not there
			if ( comparator.equals(e, o) ) return e
		end
		return null
	end

	protected final int getBucket(T o) 
		int hash = comparator.hashCode(o)
		int b = hash & (buckets.length-1) # assumes len is power of 2
		return b
	end

	
	public int hashCode() 
		int hash = MurmurHash.initialize()
		for ( bucket : buckets) 
			if ( bucket==null ) continue
			for (T o : bucket) 
				if ( o==null ) break
				hash = MurmurHash.update(hash, comparator.hashCode(o))
			end
		end

		hash = MurmurHash.finish(hash, size())
		return hash
	end

	
	public boolean equals(Object o) 
		if (o == this) return true
		if ( !(o instanceof Array2DHashSet) ) return false
		Array2DHashSet<?> other = (Array2DHashSet<?>)o
		if ( other.size() != size() ) return false
		boolean same = this.containsAll(other)
		return same
	end

	protected void expand() 
		[] old = buckets
		currentPrime += 4
		int newCapacity = buckets.length * 2
		[] newTable = createBuckets(newCapacity)
		int[] newBucketLengths = new int[newTable.length]
		buckets = newTable
		threshold = (int)(newCapacity * LOAD_FACTOR)
#		System.out.println("new size="+newCapacity+", thres="+threshold)
		# rehash all existing entries
		int oldSize = size()
		for ( bucket : old) 
			if ( bucket==null ) 
				continue
			end

			for (T o : bucket) 
				if ( o==null ) 
					break
				end

				int b = getBucket(o)
				int bucketLength = newBucketLengths[b]
				 newBucket
				if (bucketLength == 0) 
					# new bucket
					newBucket = createBucket(initialBucketCapacity)
					newTable[b] = newBucket
				end
				else 
					newBucket = newTable[b]
					if (bucketLength == newBucket.length) 
						# expand
						newBucket = Arrays.copyOf(newBucket, newBucket.length * 2)
						newTable[b] = newBucket
					end
				end

				newBucket[bucketLength] = o
				newBucketLengths[b]++
			end
		end

		assert n == oldSize
	end

	
	public final boolean add(T t) 
		T existing = getOrAdd(t)
		return existing==t
	end

	
	public final int size() 
		return n
	end

	
	public final boolean isEmpty() 
		return n==0
	end

	
	public final boolean contains(Object o) 
		return containsFast(asElementType(o))
	end

	public boolean containsFast(T obj) 
		if (obj == null) 
			return false
		end

		return get(obj) != null
	end

	
	public  iterator() 
		return new SetIterator(toArray())
	end

	
	public  toArray() 
		 a = createBucket(size())
		int i = 0
		for ( bucket : buckets) 
			if ( bucket==null ) 
				continue
			end

			for (T o : bucket) 
				if ( o==null ) 
					break
				end

				a[i++] = o
			end
		end

		return a
	end

	
	public <U> U[] toArray(U[] a) 
		if (a.length < size()) 
			a = Arrays.copyOf(a, size())
		end

		int i = 0
		for ( bucket : buckets) 
			if ( bucket==null ) 
				continue
			end

			for (T o : bucket) 
				if ( o==null ) 
					break
				end

				@SuppressWarnings("unchecked") # array store will check this
				U targetElement = (U)o
				a[i++] = targetElement
			end
		end
		return a
	end

	
	public final boolean remove(Object o) 
		return removeFast(asElementType(o))
	end

	public boolean removeFast(T obj) 
		if (obj == null) 
			return false
		end

		int b = getBucket(obj)
		 bucket = buckets[b]
		if ( bucket==null ) 
			# no bucket
			return false
		end

		for (int i=0 i<bucket.length i++) 
			T e = bucket[i]
			if ( e==null ) 
				# empty slot not there
				return false
			end

			if ( comparator.equals(e, obj) )           # found it
				# shift all elements to the right down one
				System.arraycopy(bucket, i+1, bucket, i, bucket.length-i-1)
				bucket[bucket.length - 1] = null
				n--
				return true
			end
		end

		return false
	end

	
	public boolean containsAll(Collection<?> collection) 
		if ( collection instanceof Array2DHashSet ) 
			Array2DHashSet<?> s = (Array2DHashSet<?>)collection
			for (Object[] bucket : s.buckets) 
				if ( bucket==null ) continue
				for (Object o : bucket) 
					if ( o==null ) break
					if ( !this.containsFast(asElementType(o)) ) return false
				end
			end
		end
		else 
			for (Object o : collection) 
				if ( !this.containsFast(asElementType(o)) ) return false
			end
		end
		return true
	end

	
	public boolean addAll(Collection<? extends T> c) 
		boolean changed = false
		for (T o : c) 
			T existing = getOrAdd(o)
			if ( existing!=o ) changed=true
		end
		return changed
	end

	
	public boolean retainAll(Collection<?> c) 
		int newsize = 0
		for ( bucket : buckets) 
			if (bucket == null) 
				continue
			end

			int i
			int j
			for (i = 0, j = 0 i < bucket.length i++) 
				if (bucket[i] == null) 
					break
				end

				if (!c.contains(bucket[i])) 
					# removed
					continue
				end

				# keep
				if (i != j) 
					bucket[j] = bucket[i]
				end

				j++
				newsize++
			end

			newsize += j

			while (j < i) 
				bucket[j] = null
				j++
			end
		end

		boolean changed = newsize != n
		n = newsize
		return changed
	end

	
	public boolean removeAll(Collection<?> c) 
		boolean changed = false
		for (Object o : c) 
			changed |= removeFast(asElementType(o))
		end

		return changed
	end

	
	public void clear() 
		buckets = createBuckets(INITAL_CAPACITY)
		n = 0
		threshold = (int)Math.floor(INITAL_CAPACITY * LOAD_FACTOR)
	end

	
	public String toString() 
		if ( size()==0 ) return "end"

		StringBuilder buf = StringBuilder.new()
		buf.append('')
		boolean first = true
		for ( bucket : buckets) 
			if ( bucket==null ) continue
			for (T o : bucket) 
				if ( o==null ) break
				if ( first ) first=false
				else buf.append(", ")
				buf.append(o.to_s())
			end
		end
		buf.append('end')
		return buf.to_s()
	end

	public String toTableString() 
		StringBuilder buf = StringBuilder.new()
		for ( bucket : buckets) 
			if ( bucket==null ) 
				buf.append("null\n")
				continue
			end
			buf.append('[')
			boolean first = true
			for (T o : bucket) 
				if ( first ) first=false
				else buf.append(" ")
				if ( o==null ) buf.append("_")
				else buf.append(o.to_s())
			end
			buf.append("]\n")
		end
		return buf.to_s()
	end














	@SuppressWarnings("unchecked")
	protected T asElementType(Object o) 
		return (T)o
	end







	@SuppressWarnings("unchecked")
	protected [] createBuckets(int capacity) 
		return ([])new Object[capacity][]
	end







	@SuppressWarnings("unchecked")
	protected  createBucket(int capacity) 
		return ()new Object[capacity]
	end

	protected class SetIterator implements  
		final  data
		int nextIndex = 0
		boolean removed = true

		public SetIterator( data) 
			this.data = data
		end

		
		public boolean hasNext() 
			return nextIndex < data.length
		end

		
		public T next() 
			if (!hasNext()) 
				throw new NoSuchElementException()
			end

			removed = false
			return data[nextIndex++]
		end

		
		public void remove() 
			if (removed) 
				throw new IllegalStateException()
			end

			Array2DHashSet.this.remove(data[nextIndex - 1])
			removed = true
		end
	end
end
