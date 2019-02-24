require '../antlr4/ATNConfigSet'
require 'set'

class OrderedATNConfigSet < ATNConfigSet

  class LexerConfigHashSet
    def initialize()
      super(ObjectEqualityComparator.INSTANCE)
    end
  end

  def initialize()
    @configLookup = SortedSet.new()
  end

end
