class ATNConfig

  SUPPRESS_PRECEDENCE_FILTER = 0x40000000

  attr_accessor :state
  attr_accessor :alt
  attr_accessor :context
  attr_accessor :target
  attr_accessor :reachesIntoOuterContext
  attr_accessor :semanticContext

  def initialize
    @reachesIntoOuterContext = 0
    @alt = 0
  end

  def ATNConfig_copy(old)
    @state = old.state
    @alt = old.alt
    @context = old.context
    @semanticContext = old.semanticContext
    @reachesIntoOuterContext = old.reachesIntoOuterContext
  end

  def ATNConfig_1(state, alt, context)
    ATNConfig_2(state, alt, context, SemanticContext::NONE)
  end

  def ATNConfig_2(state, alt, context, semanticContext)
    @state = state
    @alt = alt
    @context = context
    @semanticContext = semanticContext
  end

  def ATNConfig_3(c, state)
    ATNConfig_7(c, state, c.context, c.semanticContext)
  end

  def ATNConfig_4(c, state, semanticContext)
    ATNConfig_7(c, state, c.context, semanticContext)
  end

  def ATNConfig_5(c, semanticContext)
    ATNConfig_7(c, c.state, c.context, semanticContext)
  end

  def ATNConfig_6(c, state, context)
    ATNConfig_7(c, state, context, c.semanticContext)
  end

  def ATNConfig_7(c, state, context, semanticContext)
    @state = state
    @alt = c.alt
    @context = context
    @semanticContext = semanticContext
    @reachesIntoOuterContext = c.reachesIntoOuterContext
  end


  def getOuterContextDepth()
    return (@reachesIntoOuterContext & ~SUPPRESS_PRECEDENCE_FILTER)
  end

  def isPrecedenceFilterSuppressed()
    return (@reachesIntoOuterContext & SUPPRESS_PRECEDENCE_FILTER) != 0
  end

  def setPrecedenceFilterSuppressed(value)
    if (value)
      @reachesIntoOuterContext |= 0x40000000

    else
      @reachesIntoOuterContext &= ~SUPPRESS_PRECEDENCE_FILTER
    end
  end

  def toString()
    return toString_2(nil, true)
  end

  def toString_2(recog = nil, showAlt = false)
    buf = ""
    buf << '('
    buf << @state.to_s
    if (showAlt)
      buf << ","
      buf << @alt.to_s
    end
    if (@context != nil)
      buf << ",["
      buf << @context.to_s()
      buf << "]"
    end
    if (@semanticContext != nil && @semanticContext != SemanticContext::NONE)
      buf << ","
      buf << @semanticContext.to_s
    end
    if (getOuterContextDepth() > 0)
      buf << ",up=" << getOuterContextDepth().to_s
    end
    buf << ')'
    return buf
  end


  def <=>(other)
    if (self == other)
      return true
    elsif (other == nil)
      return false
    end

    return @state.stateNumber == other.state.stateNumber && @alt == other.alt && (@context == other.context || (@context != nil && @context.<=>(other.context))) && @semanticContext.<=>(other.semanticContext) && isPrecedenceFilterSuppressed() == other.isPrecedenceFilterSuppressed()
  end

  def hash()
    hashCode = 7
    hashCode = MurmurHash.update_int(hashCode, @state.stateNumber)
    hashCode = MurmurHash.update_int(hashCode, @alt)
    hashCode = MurmurHash.update_obj(hashCode, @context)
    hashCode = MurmurHash.update_obj(hashCode, @semanticContext)
    hashCode = MurmurHash.finish(hashCode, 4)
    return hashCode
  end


end
