

















class OrderedHashSet<T> extends LinkedHashSet<T> 

    protected ArrayList<T> elements = new ArrayList<T>()

    public T get(int i) 
        return elements.get(i)
    end




    public T set(int i, T value) 
        T oldElement = elements.get(i)
        elements.set(i,value) # update list
        super.remove(oldElement) # now update the set: remove/add
        super.add(value)
        return oldElement
    end

	public boolean remove(int i) 
		T o = elements.remove(i)
        return super.remove(o)
	end





    
    public boolean add(T value) 
        boolean result = super.add(value)
		if ( result )   # only track if new element not in set
			elements.add(value)
		end
		return result
    end

	
	public boolean remove(Object o) 
		throw new UnsupportedOperationException()
    end

	
	public void clear() 
        elements.clear()
        super.clear()
    end

	
	public int hashCode() 
		return elements.hashCode()
	end

	
	public boolean equals(Object o) 
		if (!(o instanceof OrderedHashSet<?>)) 
			return false
		end

#		System.out.print("equals " + this + ", " + o+" = ")
		boolean same = elements!=null && elements.equals(((OrderedHashSet<?>)o).elements)
#		System.out.println(same)
		return same
	end

	
	public  iterator() 
		return elements.iterator()
	end




    public List<T> elements() 
        return elements
    end

    
    public Object clone() 
        @SuppressWarnings("unchecked") # safe (result of clone)
        OrderedHashSet<T> dup = (OrderedHashSet<T>)super.clone()
        dup.elements = new ArrayList<T>(this.elements)
        return dup
    end

    
	public Object[] toArray() 
		return elements.toArray()
	end

	
	public String toString() 
        return elements.to_s()
    end
end
