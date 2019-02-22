require '../../antlr4/runtime/Ruby/antlr4/ATNConfigSet'
require 'set'

class OrderedATNConfigSet < ATNConfigSet

  class LexerConfigHashSet
    def initialize()
      super(ObjectEqualityComparator.INSTANCE)
    end
  end

  def initialize()
    @configLookup = Set.new()
  end

end
