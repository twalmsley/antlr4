require '../antlr4/RecognitionException'


class InputMismatchException < RecognitionException
  def self.create(recog, state = nil)
    result = InputMismatchException.new

    result.offendingState = -1
    result.context = recog._ctx
    result.input = recog.getInputStream
    result.recognizer = recog
    if recog != nil
      result.offendingState = recog.getState
    end

    result.offendingToken = recog.getCurrentToken
    if(state != nil)
      result.offendingState = state
    end
    result
  end
end
