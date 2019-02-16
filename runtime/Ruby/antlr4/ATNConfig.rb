class ATNConfig

  SUPPRESS_PRECEDENCE_FILTER = 0x40000000

  attr_accessor :state
  attr_accessor :alt
  attr_accessor :context
  attr_accessor :target
  attr_accessor :reachesIntoOuterContext
  attr_accessor :semanticContext

  def getOuterContextDepth()
    return (@reachesIntoOuterContext & ~SUPPRESS_PRECEDENCE_FILTER)
  end

end
