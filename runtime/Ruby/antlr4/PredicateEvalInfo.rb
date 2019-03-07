class PredicateEvalInfo < DecisionEventInfo


  attr_reader :semctx


  attr_reader :predictedAlt


  attr_reader :evalResult


  def initialize(decision, input, startIndex, stopIndex, semctx, evalResult, predictedAlt, fullCtx)
    super(decision, ATNConfigSet().new, input, startIndex, stopIndex, fullCtx)
    @semctx = semctx
    @evalResult = evalResult
    @predictedAlt = predictedAlt
  end
end
