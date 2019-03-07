require '../antlr4/CodePointCharStream'

class CharStreams

  DEFAULT_BUFFER_SIZE = 4096

  def self.fromString(s, sourceName)
    return CodePointCharStream.new(0, s.length, sourceName, s.bytes)
  end
end
