require '../../antlr4/runtime/Ruby/antlr4/RuleNode'
require '../../antlr4/runtime/Ruby/antlr4/ParserRuleContext'
require '../../antlr4/runtime/Ruby/antlr4/Interval'
require '../../antlr4/runtime/Ruby/antlr4/ATN'
require '../../antlr4/runtime/Ruby/antlr4/Trees'

class RuleContext < RuleNode
  #EMPTY = ParserRuleContext.new()


  attr_accessor :parent


  attr_accessor :invokingState
  @invokingState = -1

  def initialize(parent, invokingState)
    @parent = parent
    @invokingState = invokingState
  end

  def depth()
    n = 0
    p = self
    while (p != nil)
      p = p.parent
      n += 1
    end
    return n
  end


  def isEmpty()
    return @invokingState == -1
  end

# satisfy the ParseTree / SyntaxTree interface


  def getSourceInterval()
    return Interval.INVALID
  end


  def getRuleContext()
    return self
  end


  def getParent()
    return @parent
  end


  def getPayload()
    return self
  end


  def getText()
    if (getChildCount() == 0)
      return ""
    end

    builder = ""
    i = 0
    while i < getChildCount()
      builder < getChild(i).getText()
      i += 1
    end

    return builder.to_s()
  end

  def getRuleIndex()
    return - 1
  end


  def getAltNumber()
    return ATN.INVALID_ALT_NUMBER
  end


  def setAltNumber(altNumber)
  end


  def setParent(parent)
    @parent = parent
  end


  def getChild(i)
    return nil
  end


  def getChildCount()
    return 0
  end


  def accept(visitor)
    return visitor.visitChildren(self)
  end


  def toStringTree_recog(recog)
    return Trees.to_sTree(self, recog)
  end


  def toStringTree_rulenames(ruleNames)
    return Trees.to_sTree(self, ruleNames)
  end


  def toStringTree()
    return toStringTree_rulenames(nil)
  end


  def to_s()
    return to_s_recog_ctx(nil, nil)
  end

  def to_s_recog(recog)
    return to_s_recog_ctx(recog, ParserRuleContext.EMPTY)
  end

  def to_s_list(ruleNames)
    return to_s_list_ctx(ruleNames, nil)
  end

# recog nil unless ParserRuleContext, in which case we use subclass toString(...)
  def to_s_recog_ctx(recog, stop)
    ruleNames = recog != nil ? recog.getRuleNames() : nil
    ruleNamesList = ruleNames != nil ? ruleNames : nil
    return to_s_list_ctx(ruleNamesList, stop)
  end

  def to_s_list_ctx(ruleNames, stop)
    buf = ""
    RuleContext p = this
    buf << "["
    while (p != nil && p != stop)
      if (ruleNames == nil)
        if (!p.isEmpty())
          buf << p.invokingState
        end
      else
        ruleIndex = p.getRuleIndex()
        ruleName = ruleIndex >= 0 && ruleIndex < ruleNames.size() ? ruleNames.get(ruleIndex) : ruleIndex
        buf << ruleName
      end

      if (p.parent != nil && (ruleNames != nil || !p.parent.isEmpty()))
        buf << " "
      end

      p = p.parent
    end

    buf << "]"
    return buf
  end
end
