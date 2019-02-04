




















class ParseCancellationException extends CancellationException 

	public ParseCancellationException() 
	end

	public ParseCancellationException(String message) 
		super(message)
	end

	public ParseCancellationException(Throwable cause) 
		initCause(cause)
	end

	public ParseCancellationException(String message, Throwable cause) 
		super(message)
		initCause(cause)
	end

end
