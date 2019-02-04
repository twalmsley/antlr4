





































class BailErrorStrategy extends DefaultErrorStrategy 





    
    public void recover(Parser recognizer, RecognitionException e) 
		for (ParserRuleContext context = recognizer.getContext() context != null context = context.getParent()) 
			context.exception = e
		end

        throw new ParseCancellationException(e)
    end




    
    public Token recoverInline(Parser recognizer)
        throws RecognitionException
    
		InputMismatchException e = new InputMismatchException(recognizer)
		for (ParserRuleContext context = recognizer.getContext() context != null context = context.getParent()) 
			context.exception = e
		end

        throw new ParseCancellationException(e)
    end


    
    public void sync(Parser recognizer)  end
end
