
















class DoubleKeyMap<Key1, Key2, Value> 
	Map<Key1, Map<Key2, Value>> data = new LinkedHashMap<Key1, Map<Key2, Value>>()

	public Value put(Key1 k1, Key2 k2, Value v) 
		Map<Key2, Value> data2 = data.get(k1)
		Value prev = null
		if ( data2==null ) 
			data2 = new LinkedHashMap<Key2, Value>()
			data.put(k1, data2)
		end
		else 
			prev = data2.get(k2)
		end
		data2.put(k2, v)
		return prev
	end

	public Value get(Key1 k1, Key2 k2) 
		Map<Key2, Value> data2 = data.get(k1)
		if ( data2==null ) return null
		return data2.get(k2)
	end

	public Map<Key2, Value> get(Key1 k1)  return data.get(k1) end


	public Collection<Value> values(Key1 k1) 
		Map<Key2, Value> data2 = data.get(k1)
		if ( data2==null ) return null
		return data2.values()
	end


	public Set<Key1> keySet() 
		return data.keySet()
	end


	public Set<Key2> keySet(Key1 k1) 
		Map<Key2, Value> data2 = data.get(k1)
		if ( data2==null ) return null
		return data2.keySet()
	end
end
