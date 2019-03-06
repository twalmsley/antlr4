require '../antlr4/LexerIndexedCustomAction'

class LexerActionExecutor

  attr_reader :lexerActions
  attr_reader :hashCode

  def initialize(lexerActions)
    @lexerActions = lexerActions

    @hashCode = 7
    lexerActions.each do |lexerAction|
      @hashCode = MurmurHash.update_obj(@hashCode, lexerAction)
    end

    @hashCode = MurmurHash.finish(@hashCode, lexerActions.length)
  end


  def self.append(lexerActionExecutor, lexerAction)
    if (lexerActionExecutor == nil)
      return LexerActionExecutor.new([lexerAction])
    end

    lexerActions = lexerActionExecutor.lexerActions.dup
    lexerActions << lexerAction
    return LexerActionExecutor.new(lexerActions)
  end


  def fixOffsetBeforeMatch(offset)
    updatedLexerActions = nil
    i = 0
    while i < @lexerActions.length
      if (@lexerActions[i].isPositionDependent() && !(@lexerActions[i].is_a? LexerIndexedCustomAction))
        if (updatedLexerActions == nil)
          updatedLexerActions = @lexerActions.dup()
        end

        updatedLexerActions[i] = LexerIndexedCustomAction.new(offset, @lexerActions[i])
      end
      i += 1
    end

    if (updatedLexerActions == nil)
      return self
    end

    return LexerActionExecutor.new(updatedLexerActions)
  end


  def execute(lexer, input, startIndex)
    requiresSeek = false
    stopIndex = input.index()
    begin
      @lexerActions.each do |lexerAction|
        if (lexerAction.is_a? LexerIndexedCustomAction)
          offset = lexerAction.getOffset()
          input.seek(startIndex + offset)
          lexerAction = lexerAction.getAction()
          requiresSeek = ((startIndex + offset) != stopIndex)
        else
          if (lexerAction.isPositionDependent())
            input.seek(stopIndex)
            requiresSeek = false
          end

          lexerAction.execute(lexer)
        end
      end
    ensure
      if (requiresSeek)
        input.seek(stopIndex)
      end
    end
  end


  def eql?(obj)
    if (obj == self)
      return true
    else
      if (!(obj.is_a? LexerActionExecutor))
        return false
      end
    end

    return @hashCode == obj.hashCode && (@lexerActions == obj.lexerActions)
  end
end
