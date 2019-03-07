class DecisionInfo
  attr_accessor :decision
  attr_accessor :invocations
  attr_accessor :timeInPrediction
  attr_accessor :SLL_TotalLook
  attr_accessor :SLL_MinLook
  attr_accessor :SLL_MaxLook
  attr_accessor :SLL_MaxLookEvent
  attr_accessor :LL_TotalLook
  attr_accessor :LL_MinLook
  attr_accessor :LL_MaxLook
  attr_accessor :LL_MaxLookEvent
  attr_accessor :contextSensitivities
  attr_accessor :errors
  attr_accessor :ambiguities
  attr_accessor :predicateEvals
  attr_accessor :SLL_ATNTransitions
  attr_accessor :SLL_DFATransitions
  attr_accessor :LL_Fallback
  attr_accessor :LL_ATNTransitions
  attr_accessor :LL_DFATransitions

  def initialize(decision)
    @contextSensitivities = []
    @errors = []
    @ambiguities = []
    @predicateEvals = []
    @decision = decision
  end

  def to_s()
    return "" +
        "decision=" + @decision +
        ", contextSensitivities=" + @contextSensitivities.size() +
        ", errors=" + @errors.size() +
        ", ambiguities=" + @ambiguities.size() +
        ", SLL_lookahead=" + SLL_TotalLook +
        ", SLL_ATNTransitions=" + SLL_ATNTransitions +
        ", SLL_DFATransitions=" + SLL_DFATransitions +
        ", LL_Fallback=" + LL_Fallback +
        ", LL_lookahead=" + LL_TotalLook +
        ", LL_ATNTransitions=" + LL_ATNTransitions +
        'end'
  end
end
