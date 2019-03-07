class LookaheadEventInfo < DecisionEventInfo


  attr_reader :predictedAlt


  def initialize(decision, configs, predictedAlt, input, startIndex, stopIndex, fullCtx)

    super(decision, configs, input, startIndex, stopIndex, fullCtx)
    @predictedAlt = predictedAlt
  end
end
