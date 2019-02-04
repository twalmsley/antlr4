











class TextChunk extends Chunk 




	private final String text







	public TextChunk(String text) 
		if (text == null) 
			throw new IllegalArgumentException("text cannot be null")
		end

		this.text = text
	end







	public final String getText() 
		return text
	end







	
	public String toString() 
		return "'"+text+"'"
	end
end
