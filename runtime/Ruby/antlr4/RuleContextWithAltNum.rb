require '../antlr4/ParserRuleContext'

class RuleContextWithAltNum < ParserRuleContext
  attr_accessor :altNum

  def initialize(parent = nil, invokingStateNumber = nil)
    super(parent, invokingStateNumber)
    @altNum = ATN::INVALID_ALT_NUMBER
  end

end
