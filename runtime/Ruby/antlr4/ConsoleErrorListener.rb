class ConsoleErrorListener


  class << self
    attr_reader :INSTANCE
  end

  @@INSTANCE = ConsoleErrorListener.new


  def syntaxError(recognizer,
                  offendingSymbol,
                  line,
                  charPositionInLine,
                  msg,
                  e)

    STDERR.printf "line %d:%d %s" % [line, charPositionInLine, msg]
  end

end
