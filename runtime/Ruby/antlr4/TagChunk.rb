





















class TagChunk extends Chunk 



	private final String tag



	private final String label











	public TagChunk(String tag) 
		this(null, tag)
	end













	public TagChunk(String label, tag) 
		if (tag == null || tag.isEmpty()) 
			throw new IllegalArgumentException("tag cannot be null or empty")
		end

		this.label = label
		this.tag = tag
	end







	public final String getTag() 
		return tag
	end








	public final String getLabel() 
		return label
	end






	
	public String toString() 
		if (label != null) 
			return label + ":" + tag
		end

		return tag
	end
end
