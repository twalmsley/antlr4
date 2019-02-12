require '../../antlr4/runtime/Ruby/antlr4/ATNConfigSet'
require '../../antlr4/runtime/Ruby/antlr4/AbstractConfigHashSet'

class OrderedATNConfigSet < ATNConfigSet

  class LexerConfigHashSet < AbstractConfigHashSet
    def initialize()
      super(ObjectEqualityComparator.INSTANCE)
    end
  end

  def initialize()
    @configLookup = LexerConfigHashSet.new()
  end

end
