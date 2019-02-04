require 'DecisionEventInfo'

class AmbiguityInfo < DecisionEventInfo
  def initialize(decision,
                 configs,
                 ambigAlts,
                 input, startIndex, stopIndex,
                 fullCtx)

    super(decision, configs, input, startIndex, stopIndex, fullCtx)
    @ambigAlts = ambigAlts
  end
end
