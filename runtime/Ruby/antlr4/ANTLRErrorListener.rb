class ANTLRErrorListener
  def syntaxError(recognizer,
                  offendingSymbol,
                  line,
                  charPositionInLine,
                  msg,
                  e)
  end

  def reportAmbiguity(recognizer,
                      dfa,
                      startIndex,
                      stopIndex,
                      exact,
                      ambigAlts,
                      configs)
  end

  def reportAttemptingFullContext(recognizer,
                                  dfa,
                                  startIndex,
                                  stopIndex,
                                  conflictingAlts,
                                  configs)
  end

  def reportContextSensitivity(recognizer,
                               dfa,
                               startIndex,
                               stopIndex,
                               prediction,
                               configs)
  end
end
