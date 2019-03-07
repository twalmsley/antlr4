class ProxyErrorListener

  def initialize(delegates)
    if (delegates == nil)
      raise StandardError, "delegates is nil"
    end

    @delegates = delegates
  end


  def syntaxError(recognizer,
                  offendingSymbol,
                  line,
                  charPositionInLine,
                  msg,
                  e)

    @delegates.each do |listener|
      listener.syntaxError(recognizer, offendingSymbol, line, charPositionInLine, msg, e)
    end
  end


  def reportAmbiguity(recognizer,
                      dfa,
                      startIndex,
                      stopIndex,
                      exact,
                      ambigAlts,
                      configs)

    @delegates.each do |listener|
      listener.reportAmbiguity(recognizer, dfa, startIndex, stopIndex, exact, ambigAlts, configs)
    end
  end


  def reportAttemptingFullContext(recognizer,
                                  dfa,
                                  startIndex,
                                  stopIndex,
                                  conflictingAlts,
                                  configs)

    @delegates.each do |listener|
      listener.reportAttemptingFullContext(recognizer, dfa, startIndex, stopIndex, conflictingAlts, configs)
    end
  end


  def reportContextSensitivity(recognizer,
                               dfa,
                               startIndex,
                               stopIndex,
                               prediction,
                               configs)

    @delegates.each do |listener|
      listener.reportContextSensitivity(recognizer, dfa, startIndex, stopIndex, prediction, configs)
    end
  end
end
