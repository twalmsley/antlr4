class ContextSensitivityInfo < DecisionEventInfo


  def initialize(decision, configs, input, startIndex, stopIndex)

    super(decision, configs, input, startIndex, stopIndex, true)
  end
end
