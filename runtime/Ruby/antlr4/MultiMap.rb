class MultiMap < K
  , V > extends LinkedHashMap < K, List < V >>
      public void map(K key, V value)
  List < V > elementsForKey = get(key)
  if (elementsForKey == null)
    elementsForKey = new ArrayList < V > ()
    super.put(key, elementsForKey)
  end
  elementsForKey.add(value)
end

public List < Pair < K, V >> getPairs()
List < Pair < K, V >> pairs = new ArrayList < Pair < K, V >> ()
for (K key :
  keySet())
  for (V value :
    get(key))
    pairs.add(new Pair < K, V > (key, value))
  end
end
return pairs
end
end
