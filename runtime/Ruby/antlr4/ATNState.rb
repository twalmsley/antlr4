require '../antlr4/IntervalSet'

class ATNState
  INITIAL_NUM_TRANSITIONS = 4
  INVALID_TYPE = 0
  BASIC = 1
  RULE_START = 2
  BLOCK_START = 3
  PLUS_BLOCK_START = 4
  STAR_BLOCK_START = 5
  TOKEN_START = 6
  RULE_STOP = 7
  BLOCK_END = 8
  STAR_LOOP_BACK = 9
  STAR_LOOP_ENTRY = 10
  PLUS_LOOP_BACK = 11
  LOOP_END = 12

  @@serializationNames = %w(INVALID BASIC RULE_START BLOCK_START PLUS_BLOCK_START STAR_BLOCK_START TOKEN_START RULE_STOP BLOCK_END STAR_LOOP_BACK STAR_LOOP_ENTRY PLUS_LOOP_BACK LOOP_END)

  @@INVALID_STATE_NUMBER = -1

  class << self
    attr_accessor :INVALID_STATE_NUMBER
  end

  attr_accessor :nextTokenWithinRule
  attr_accessor :atn
  attr_accessor :stateNumber
  attr_accessor :ruleIndex

  def initialize
    @atn = nil
    @stateNumber = @@INVALID_STATE_NUMBER
    @ruleIndex = 0
    @epsilonOnlyTransitions = false
    @transitions = []
    @nextTokenWithinRule = nil
  end

  def hash
    @stateNumber
  end

  def eql?(other_key)
    @stateNumber == other_key.stateNumber
  end

  def isNonGreedyExitState
    false
  end

  def to_s
    @stateNumber.to_s
  end

  def getTransitions
    @transitions
  end

  def getNumberOfTransitions
    @transitions.length
  end

  def addTransition(e)
    self.addTransition_at(@transitions.length, e)
  end

  def addTransition_at(index, e)
    if @transitions.empty?

      @epsilonOnlyTransitions = e.isEpsilon

    elsif @epsilonOnlyTransitions != e.isEpsilon

      STDERR.puts "ATN state %d has both epsilon and non-epsilon transitions.\n" % [stateNumber]
      @epsilonOnlyTransitions = false
    end
    alreadyPresent = false

    @transitions.each do |t|
      if t.target.stateNumber == e.target.stateNumber

        if t.label != nil && e.label != nil && t.label.equals(e.label)
          alreadyPresent = true
          break
        elsif t.isEpsilon && e.isEpsilon
          alreadyPresent = true
          break
        end
      end
    end

    if !alreadyPresent
      @transitions[index] = e
    end
  end

  def transition(i)
    @transitions[i]
  end

  def setTransition(i, e)
    @transitions[i] = e
  end

  def removeTransition(index)
    @transitions.delete_at index
  end


  def onlyHasEpsilonTransitions
    @epsilonOnlyTransitions
  end

  def setRuleIndex(ruleIndex)
    @ruleIndex = ruleIndex
  end
end
