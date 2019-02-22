require 'singleton'

class ConsoleErrorListener
  include Singleton

  def syntaxError(recognizer,
                  offendingSymbol,
                  line,
                  charPositionInLine,
                  msg,
                  e)

    STDERR.printf "line %d:%d %s\n" % [line, charPositionInLine, msg]
  end

end
