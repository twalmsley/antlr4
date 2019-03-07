require '../antlr4/Chunk'

class TagChunk < Chunk

  attr_reader :tag
  attr_reader :label

  def initialize(label, tag)
    if (tag == nil || tag.isEmpty())
      raise IllegalArgumentException, "tag cannot be nil or empty"
    end

    @label = label
    @tag = tag
  end


  def to_s()
    if (@label != nil)
      return @label + ":" + @tag
    end

    return @tag
  end
end
