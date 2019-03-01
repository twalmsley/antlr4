class SemanticContext

  def eval(parser, parserCallStack)
  end


  def evalPrecedence(parser, parserCallStack)
    return self
  end

  class Predicate < SemanticContext
    attr_accessor :ruleIndex
    attr_accessor :predIndex
    attr_accessor :isCtxDependent # e.g., $i ref in pred

    def initialize(ruleIndex = -1, predIndex = -1, isCtxDependent = false)
      @ruleIndex = ruleIndex
      @predIndex = predIndex
      @isCtxDependent = isCtxDependent
    end


    def eval(parser, parserCallStack)
      localctx = @isCtxDependent ? parserCallStack : nil
      return parser.sempred(localctx, @ruleIndex, @predIndex)
    end


    def hash()
      hashCode = 0
      hashCode = MurmurHash.update_int(hashCode, @ruleIndex)
      hashCode = MurmurHash.update_int(hashCode, @predIndex)
      hashCode = MurmurHash.update_int(hashCode, @isCtxDependent ? 1 : 0)
      hashCode = MurmurHash.finish(hashCode, 3)
      return hashCode
    end


    def equals(obj)
      if (!(obj.is_a? Predicate))
        return false
      end
      if (self == obj)
        return true
      end
      p = obj
      return @ruleIndex == p.ruleIndex &&
          @predIndex == p.predIndex &&
          @isCtxDependent == p.isCtxDependent
    end


    def to_s()
      return "" + @ruleIndex + ":" + @predIndex + "end?"
    end
  end

  class PrecedencePredicate < SemanticContext
    attr_accessor :precedence

    def initialize(precedence = 0)
      @precedence = precedence
    end


    def eval(parser, parserCallStack)
      return parser.precpred(parserCallStack, @precedence)
    end


    def evalPrecedence(parser, parserCallStack)
      if (parser.precpred(parserCallStack, @precedence))
        return SemanticContext::NONE
      else
        return nil
      end
    end


    def compareTo(o)
      return @precedence - o.precedence
    end


    def hash()
      hashCode = 1
      hashCode = 31 * hashCode + @precedence
      return hashCode
    end


    def eql?(obj)
      if (!(obj.is_a? PrecedencePredicate))
        return false
      end

      if (self == obj)
        return true
      end

      other = obj
      return @precedence == other.precedence
    end


# precedence >= _precedenceStack.peek()
    def to_s()
      return "" + @precedence + ">=precend?"
    end
  end


  class Operator < SemanticContext

    def getOperands()
    end
  end


  class AND < Operator
    attr_accessor :opnds

    def initialize(a, b)
      operands = Set.new
      if (a.is_a? AND)
        operands.addAll(a.opnds)
      else
        operands.add(a)
      end
      if (b.is_a? AND)
        operands.addAll(b.opnds)
      else
        operands.add(b)
      end
      precedencePredicates = filterPrecedencePredicates(operands)
      if (!precedencePredicates.empty?)
        # interested in the transition with the lowest precedence
        reduced = precedencePredicates.min
        operands.add(reduced)
      end

      @opnds = operands.to_a
    end

    def eql?(obj)
      if (self == obj)
        return true
      end
      if (!(obj.is_a? AND))
        return false
      end
      other = obj
      return @opnds.equals(other.opnds)
    end


    def hash()
      return MurmurHash.hash(@opnds, AND.hash)
    end


    def eval(parser, parserCallStack)
      @opnds.each do |opnd|
        if (!opnd.eval(parser, parserCallStack))
          return false
        end
      end
      return true
    end


    def evalPrecedence(parser, parserCallStack)
      differs = false
      operands = []
      @opnds.each do |context|
        evaluated = context.evalPrecedence(parser, parserCallStack)
        differs |= (evaluated != context)
        if (evaluated == null)
          # The AND context is false if any element is false
          return nil
        elsif (evaluated != NONE)
          # Reduce the result by skipping true elements
          operands.add(evaluated)
        end
      end

      if (!differs)
        return self
      end

      if (operands.empty?)
        # all elements were true, so the AND context is true
        return NONE
      end

      result = operands[0]
      i = 1
      while i < operands.length
        result = SemanticContext.and(result, operands.get(i))
        i += 1
      end

      return result
    end


    def to_s()
      return @opnds.join("&&")
    end
  end


  class OR < Operator
    attr_accessor :opnds

    def initialize(a, b)
      operands = Set.new
      if (a.is_a? OR)
        operands.addAll(a.opnds)
      else
        operands.add(a)
      end
      if (b.is_a? OR)
        operands.addAll(b.opnds)
      else
        operands.add(b)
      end

      precedencePredicates = filterPrecedencePredicates(operands)
      if (!precedencePredicates.empty?)
        # interested in the transition with the highest precedence
        reduced = precedencePredicates.max
        operands.add(reduced)
      end

      @opnds = operands.to_s
    end

    def eql?(obj)
      if (self == obj)
        return true
      end
      if (!(obj.is_a? OR))
        return false
      end
      other = obj
      return @opnds.eql?(other.opnds)
    end


    def hash()
      return MurmurHash.hash(@opnds, OR.hash())
    end


    def eval(parser, parserCallStack)
      @opnds.each do |opnd|
        if (opnd.eval(parser, parserCallStack))
          return true
        end
      end
      return false
    end


    def evalPrecedence(parser, parserCallStack)
      differs = false
      operands = []
      @opnds.each do |context|
        evaluated = context.evalPrecedence(parser, parserCallStack)
        differs |= (evaluated != context)
        if (evaluated == NONE)
          # The OR context is true if any element is true
          return NONE
        elsif (evaluated != null)
          # Reduce the result by skipping false elements
          operands.add(evaluated)
        end
      end
      if (!differs)
        return self
      end

      if (operands.isEmpty())
        # all elements were false, so the OR context is false
        return nil
      end

      result = operands[0]
      i = 1
      while i < operands.size()
        result = SemanticContext.or(result, operands.get(i))
        i += 1
      end

      return result
    end


    def to_s()
      return @opnds.join("||")
    end
  end

  def self.and(a, b)
    if (a == nil || a == NONE)
      return b
    end
    if (b == nil || b == NONE)
      return a
    end
    result = AND.new(a, b)
    if (result.opnds.length == 1)
      return result.opnds[0]
    end

    return result
  end


  def self.or(a, b)
    if (a == nil)
      return b
    end
    if (b == nil)
      return a
    end
    if (a == NONE || b == NONE)
      return NONE
    end
    OR result = OR.new(a, b)
    if (result.opnds.length == 1)
      return result.opnds[0]
    end

    return result
  end

  def self.filterPrecedencePredicates(collection)
    result = collection.select {|item| item.is_a? PrecedencePredicate}
    collection.select! {|item| !(item.is_a? PrecedencePredicate)}
    return result
  end

  NONE = Predicate.new

end
