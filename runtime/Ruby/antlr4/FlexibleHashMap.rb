

















class FlexibleHashMap<K,V> implements Map<K, V> 
	public static final int INITAL_CAPACITY = 16 # must be power of 2
	public static final int INITAL_BUCKET_CAPACITY = 8
	public static final double LOAD_FACTOR = 0.75

	public static class Entry<K, V> 
		public final K key
		public V value

		public Entry(K key, V value)  this.key = key this.value = value end

		
		public String toString() 
			return key.to_s()+":"+value.to_s()
		end
	end


	protected final AbstractEqualityComparator<? super K> comparator

	protected LinkedList<Entry<K, V>>[] buckets


	protected int n = 0

	protected int threshold = (int)(INITAL_CAPACITY * LOAD_FACTOR) # when to expand

	protected int currentPrime = 1 # jump by 4 primes each expand or whatever
	protected int initialBucketCapacity = INITAL_BUCKET_CAPACITY

	public FlexibleHashMap() 
		this(null, INITAL_CAPACITY, INITAL_BUCKET_CAPACITY)
	end

	public FlexibleHashMap(AbstractEqualityComparator<? super K> comparator) 
		this(comparator, INITAL_CAPACITY, INITAL_BUCKET_CAPACITY)
	end

	public FlexibleHashMap(AbstractEqualityComparator<? super K> comparator, int initialCapacity, int initialBucketCapacity) 
		if (comparator == null) 
			comparator = ObjectEqualityComparator.INSTANCE
		end

		this.comparator = comparator
		this.buckets = createEntryListArray(initialBucketCapacity)
		this.initialBucketCapacity = initialBucketCapacity
	end

	private static <K, V> LinkedList<Entry<K, V>>[] createEntryListArray(int length) 
		@SuppressWarnings("unchecked")
		LinkedList<Entry<K, V>>[] result = (LinkedList<Entry<K, V>>[])new LinkedList<?>[length]
		return result
	end

	protected int getBucket(K key) 
		int hash = comparator.hashCode(key)
		int b = hash & (buckets.length-1) # assumes len is power of 2
		return b
	end

	
	public V get(Object key) 
		@SuppressWarnings("unchecked")
		K typedKey = (K)key
		if ( key==null ) return null
		int b = getBucket(typedKey)
		LinkedList<Entry<K, V>> bucket = buckets[b]
		if ( bucket==null ) return null # no bucket
		for (Entry<K, V> e : bucket) 
			if ( comparator.equals(e.key, typedKey) ) 
				return e.value
			end
		end
		return null
	end

	
	public V put(K key, V value) 
		if ( key==null ) return null
		if ( n > threshold ) expand()
		int b = getBucket(key)
		LinkedList<Entry<K, V>> bucket = buckets[b]
		if ( bucket==null ) 
			bucket = buckets[b] = new LinkedList<Entry<K, V>>()
		end
		for (Entry<K, V> e : bucket) 
			if ( comparator.equals(e.key, key) ) 
				V prev = e.value
				e.value = value
				n++
				return prev
			end
		end
		# not there
		bucket.add(new Entry<K, V>(key, value))
		n++
		return null
	end

	
	public V remove(Object key) 
		throw new UnsupportedOperationException()
	end

	
	public void putAll(Map<? extends K, ? extends V> m) 
		throw new UnsupportedOperationException()
	end

	
	public Set<K> keySet() 
		throw new UnsupportedOperationException()
	end

	
	public Collection<V> values() 
		List<V> a = new ArrayList<V>(size())
		for (LinkedList<Entry<K, V>> bucket : buckets) 
			if ( bucket==null ) continue
			for (Entry<K, V> e : bucket) 
				a.add(e.value)
			end
		end
		return a
	end

	
	public Set<Map.Entry<K, V>> entrySet() 
		throw new UnsupportedOperationException()
	end

	
	public boolean containsKey(Object key) 
		return get(key)!=null
	end

	
	public boolean containsValue(Object value) 
		throw new UnsupportedOperationException()
	end

	
	public int hashCode() 
		int hash = MurmurHash.initialize()
		for (LinkedList<Entry<K, V>> bucket : buckets) 
			if ( bucket==null ) continue
			for (Entry<K, V> e : bucket) 
				if ( e==null ) break
				hash = MurmurHash.update(hash, comparator.hashCode(e.key))
			end
		end

		hash = MurmurHash.finish(hash, size())
		return hash
	end

	
	public boolean equals(Object o) 
		throw new UnsupportedOperationException()
	end

	protected void expand() 
		LinkedList<Entry<K, V>>[] old = buckets
		currentPrime += 4
		int newCapacity = buckets.length * 2
		LinkedList<Entry<K, V>>[] newTable = createEntryListArray(newCapacity)
		buckets = newTable
		threshold = (int)(newCapacity * LOAD_FACTOR)
#		System.out.println("new size="+newCapacity+", thres="+threshold)
		# rehash all existing entries
		int oldSize = size()
		for (LinkedList<Entry<K, V>> bucket : old) 
			if ( bucket==null ) continue
			for (Entry<K, V> e : bucket) 
				if ( e==null ) break
				put(e.key, e.value)
			end
		end
		n = oldSize
	end

	
	public int size() 
		return n
	end

	
	public boolean isEmpty() 
		return n==0
	end

	
	public void clear() 
		buckets = createEntryListArray(INITAL_CAPACITY)
		n = 0
	end

	
	public String toString() 
		if ( size()==0 ) return "end"

		StringBuilder buf = StringBuilder.new()
		buf.append('')
		boolean first = true
		for (LinkedList<Entry<K, V>> bucket : buckets) 
			if ( bucket==null ) continue
			for (Entry<K, V> e : bucket) 
				if ( e==null ) break
				if ( first ) first=false
				else buf.append(", ")
				buf.append(e.to_s())
			end
		end
		buf.append('end')
		return buf.to_s()
	end

	public String toTableString() 
		StringBuilder buf = StringBuilder.new()
		for (LinkedList<Entry<K, V>> bucket : buckets) 
			if ( bucket==null ) 
				buf.append("null\n")
				continue
			end
			buf.append('[')
			boolean first = true
			for (Entry<K, V> e : bucket) 
				if ( first ) first=false
				else buf.append(" ")
				if ( e==null ) buf.append("_")
				else buf.append(e.to_s())
			end
			buf.append("]\n")
		end
		return buf.to_s()
	end

	def self.main(String[] args) 
		FlexibleHashMap<String,Integer> map = new FlexibleHashMap<String,Integer>()
		map.put("hi", 1)
		map.put("mom", 2)
		map.put("foo", 3)
		map.put("ach", 4)
		map.put("cbba", 5)
		map.put("d", 6)
		map.put("edf", 7)
		map.put("mom", 8)
		map.put("hi", 9)
		System.out.println(map)
		System.out.println(map.toTableString())
	end
end
