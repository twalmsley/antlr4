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
      buf << @alt
    end
    if (@context != nil)
      buf << ",["
      buf << @context.to_s()
      buf << "]"
    end
    if (@semanticContext != nil && @semanticContext != SemanticContext::NONE)
      buf << ","
      buf << @semanticContext
    end
    if (getOuterContextDepth() > 0)
      buf << ",up=" << getOuterContextDepth()
    end
    buf << ')'
    return buf
  end

end
