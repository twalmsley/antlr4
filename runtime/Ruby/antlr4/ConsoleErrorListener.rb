require '../antlr4/BaseErrorListener'
require 'singleton'

class ConsoleErrorListener < BaseErrorListener
  include Singleton

  def syntaxError(recognizer,
                  offendingSymbol,
                  line,
                  charPositionInLine,
                  msg,
                  e)

    STDERR.puts "line " << line.to_s << ":" << charPositionInLine.to_s << " " << msg.to_s << ""
  end

end
