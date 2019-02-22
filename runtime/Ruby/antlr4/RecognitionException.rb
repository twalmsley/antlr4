class RecognitionException < StandardError
  attr_accessor :recognizer
  attr_accessor :context
  attr_accessor :offendingToken
  attr_accessor :offendingState
  attr_accessor :input

  def getExpectedTokens()
    if (@recognizer != nil)
      return @recognizer.getATN().getExpectedTokens(@offendingState, @context)
    end

    return nil
  end


end
