


















public final class LexerChannelAction implements LexerAction 
	private final int channel





	public LexerChannelAction(int channel) 
		this.channel = channel
	end






	public int getChannel() 
		return channel
	end





	
	public LexerActionType getActionType() 
		return LexerActionType.CHANNEL
	end





	
	public boolean isPositionDependent() 
		return false
	end







	
	public void execute(Lexer lexer) 
		lexer.setChannel(channel)
	end

	
	public int hashCode() 
		int hash = MurmurHash.initialize()
		hash = MurmurHash.update(hash, getActionType().ordinal())
		hash = MurmurHash.update(hash, channel)
		return MurmurHash.finish(hash, 2)
	end

	
	public boolean equals(Object obj) 
		if (obj == this) 
			return true
		end
		else if (!(obj instanceof LexerChannelAction)) 
			return false
		end

		return channel == ((LexerChannelAction)obj).channel
	end

	
	public String toString() 
		return String.format("channel(%d)", channel)
	end
end
