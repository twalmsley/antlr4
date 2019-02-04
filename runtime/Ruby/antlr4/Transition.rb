class Transition
  EPSILON = 1
  RANGE = 2
  RULE = 3
  PREDICATE = 4
  ATOM = 5
  ACTION = 6
  SET = 7
  NOT_SET = 8
  WILDCARD = 9
  PRECEDENCE = 10


  @@serializationNames =
      %w(INVALID EPSILON RANGE RULE PREDICATE ATOM ACTION SET NOT_SET WILDCARD PRECEDENCE)

  @@serializationTypes = Hash.new

  @@serializationTypes[:EpsilonTransition] = EPSILON
  @@serializationTypes[:RangeTransition] = RANGE
  @@serializationTypes[:RuleTransition] = RULE
  @@serializationTypes[:PredicateTransition] = PREDICATE
  @@serializationTypes[:AtomTransition] = ATOM
  @@serializationTypes[:ActionTransition] = ACTION
  @@serializationTypes[:SetTransition] = SET
  @@serializationTypes[:NotSetTransition] = NOT_SET
  @@serializationTypes[:WildcardTransition] = WILDCARD
  @@serializationTypes[:PrecedencePredicateTransition] = PRECEDENCE

  attr_accessor :target

  def initialize(target)
    if (target == nil)
      raise "target cannot be null."
    end
    @target = target
  end

  def getSerializationType()

  end

  def isEpsilon()
    return false
  end


  def label()
    return nil
  end

  def matches(symbol, minVocabSymbol, maxVocabSymbol)

  end
end

  