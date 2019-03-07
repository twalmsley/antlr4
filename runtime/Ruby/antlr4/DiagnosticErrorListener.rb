class DiagnosticErrorListener < BaseErrorListener

  def initialize(exactOnly = true)
    @exactOnly = exactOnly
  end


  def reportAmbiguity(recognizer, dfa, startIndex, stopIndex, exact, ambigAlts, configs)

    if (@exactOnly && !exact)
      return
    end

    format = "reportAmbiguity d=%s: ambigAlts=%s, input='%s'"
    decision = getDecisionDescription(recognizer, dfa)
    conflictingAlts = getConflictingAlts(ambigAlts, configs)
    text = recognizer.getTokenStream().getText(Interval.of(startIndex, stopIndex))
    message = String.format(format, decision, conflictingAlts, text)
    recognizer.notifyErrorListeners(message)
  end


  def reportAttemptingFullContext(recognizer, dfa, startIndex, stopIndex, conflictingAlts, configs)
    format = "reportAttemptingFullContext d=%s, input='%s'"
    decision = getDecisionDescription(recognizer, dfa)
    text = recognizer.getTokenStream().getText(Interval.of(startIndex, stopIndex))
    message = String.format(format, decision, text)
    recognizer.notifyErrorListeners(message)
  end


  def reportContextSensitivity(recognizer, dfa, startIndex, stopIndex, prediction, configs)
    format = "reportContextSensitivity d=%s, input='%s'"
    decision = getDecisionDescription(recognizer, dfa)
    text = recognizer.getTokenStream().getText(Interval.of(startIndex, stopIndex))
    message = String.format(format, decision, text)
    recognizer.notifyErrorListeners(message)
  end

  def getDecisionDescription(recognizer, dfa)
    decision = dfa.decision
    ruleIndex = dfa.atnStartState.ruleIndex

    ruleNames = recognizer.getRuleNames()
    if (ruleIndex < 0 || ruleIndex >= ruleNames.length)
      return decision.to_s
    end

    ruleName = ruleNames[ruleIndex]
    if (ruleName == nil || ruleName.empty?)
      return decision.to_s
    end

    return String.format("%d (%s)", decision, ruleName)
  end


  def getConflictingAlts(reportedAlts, configs)
    if (reportedAlts != nil)
      return reportedAlts
    end

    result = BitSet.new
    configs.each do |config|
      result.set(config.alt)
    end

    return result
  end
end
