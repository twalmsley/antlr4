require '../antlr4/Transition'

class AbstractPredicateTransition < Transition
  def initialize(target)
    super(target)
  end
end
