require '../antlr4/Chunk'

class TextChunk < Chunk

  attr_reader :text

  def initialize(text)
    if (text == nil)
      raise IllegalArgumentException, "text cannot be null"
    end

    @text = text
  end

  def getText()
    return @text
  end

  def to_s()
    return "'" + @text + "'"
  end
end
