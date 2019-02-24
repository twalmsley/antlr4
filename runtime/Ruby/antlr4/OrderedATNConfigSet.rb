require '../antlr4/ATNConfigSet'

class OrderedATNConfigSet < ATNConfigSet

  class LexerConfigHashSet < AbstractConfigHashSet
    def initialize()
      super(ObjectEqualityComparator.instance)
    end
  end

  def initialize()
    super
    @configLookup = LexerConfigHashSet.new
  end

end
