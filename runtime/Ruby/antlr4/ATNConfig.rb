

















class ATNConfig 





	private static final int SUPPRESS_PRECEDENCE_FILTER = 0x40000000


	public final ATNState state


	public final int alt





	public PredictionContext context
























	public int reachesIntoOuterContext


    public final SemanticContext semanticContext

	public ATNConfig(ATNConfig old)  # dup
		this.state = old.state
		this.alt = old.alt
		this.context = old.context
		this.semanticContext = old.semanticContext
		this.reachesIntoOuterContext = old.reachesIntoOuterContext
	end

	public ATNConfig(ATNState state,
					 int alt,
					 PredictionContext context)
	
		this(state, alt, context, SemanticContext.NONE)
	end

	public ATNConfig(ATNState state,
					 int alt,
					 PredictionContext context,
					 SemanticContext semanticContext)
	
		this.state = state
		this.alt = alt
		this.context = context
		this.semanticContext = semanticContext
	end

    public ATNConfig(ATNConfig c, ATNState state) 
   		this(c, state, c.context, c.semanticContext)
   	end

	public ATNConfig(ATNConfig c, ATNState state,
		 SemanticContext semanticContext)

		this(c, state, c.context, semanticContext)
	end

	public ATNConfig(ATNConfig c,
					 SemanticContext semanticContext)
	
		this(c, c.state, c.context, semanticContext)
	end

    public ATNConfig(ATNConfig c, ATNState state,
					 PredictionContext context)
	
        this(c, state, context, c.semanticContext)
    end

	public ATNConfig(ATNConfig c, ATNState state,
					 PredictionContext context,
                     SemanticContext semanticContext)
    
		this.state = state
		this.alt = c.alt
		this.context = context
		this.semanticContext = semanticContext
		this.reachesIntoOuterContext = c.reachesIntoOuterContext
	end






	public final int getOuterContextDepth() 
		return reachesIntoOuterContext & ~SUPPRESS_PRECEDENCE_FILTER
	end

	public final boolean isPrecedenceFilterSuppressed() 
		return (reachesIntoOuterContext & SUPPRESS_PRECEDENCE_FILTER) != 0
	end

	public final void setPrecedenceFilterSuppressed(boolean value) 
		if (value) 
			this.reachesIntoOuterContext |= 0x40000000
		end
		else 
			this.reachesIntoOuterContext &= ~SUPPRESS_PRECEDENCE_FILTER
		end
	end





    
    public boolean equals(Object o) 
		if (!(o instanceof ATNConfig)) 
			return false
		end

		return this.equals((ATNConfig)o)
	end

	public boolean equals(ATNConfig other) 
		if (this == other) 
			return true
		end
		else if (other == null) 
			return false
		end

		return this.state.stateNumber==other.state.stateNumber
			&& this.alt==other.alt
			&& (this.context==other.context || (this.context != null && this.context.equals(other.context)))
			&& this.semanticContext.equals(other.semanticContext)
			&& this.isPrecedenceFilterSuppressed() == other.isPrecedenceFilterSuppressed()
	end

	
	public int hashCode() 
		int hashCode = MurmurHash.initialize(7)
		hashCode = MurmurHash.update(hashCode, state.stateNumber)
		hashCode = MurmurHash.update(hashCode, alt)
		hashCode = MurmurHash.update(hashCode, context)
		hashCode = MurmurHash.update(hashCode, semanticContext)
		hashCode = MurmurHash.finish(hashCode, 4)
		return hashCode
	end

	
	public String toString() 
		return toString(null, true)
	end

	public String toString(Recognizer<?, ?> recog, boolean showAlt) 
		StringBuilder buf = StringBuilder.new()
#		if ( state.ruleIndex>=0 ) 
#			if ( recog!=null ) buf.append(recog.getRuleNames()[state.ruleIndex]+":")
#			else buf.append(state.ruleIndex+":")
#		end
		buf.append('(')
		buf.append(state)
		if ( showAlt ) 
            buf.append(",")
            buf.append(alt)
        end
        if ( context!=null ) 
            buf.append(",[")
            buf.append(context.to_s())
			buf.append("]")
        end
        if ( semanticContext!=null && semanticContext != SemanticContext.NONE ) 
            buf.append(",")
            buf.append(semanticContext)
        end
        if ( getOuterContextDepth()>0 ) 
            buf.append(",up=").append(getOuterContextDepth())
        end
		buf.append(')')
		return buf.to_s()
    end
end
