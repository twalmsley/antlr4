


























class ParseTreeProperty<V> 
	protected Map<ParseTree, V> annotations = new IdentityHashMap<ParseTree, V>()

	public V get(ParseTree node)  return annotations.get(node) end
	public void put(ParseTree node, V value)  annotations.put(node, value) end
	public V removeFrom(ParseTree node)  return annotations.remove(node) end
end
