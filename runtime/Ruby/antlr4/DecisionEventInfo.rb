class DecisionEventInfo
  attr_accessor :decision
  attr_accessor :configs
  attr_accessor :input
  attr_accessor :startIndex
  attr_accessor :stopIndex
  attr_accessor :fullCtx

  def initialize(decision,
                 configs,
                 input, startIndex, stopIndex,
                 fullCtx)

    @decision = decision
    @fullCtx = fullCtx
    @stopIndex = stopIndex
    @input = input
    @startIndex = startIndex
    @configs = configs
  end
end
