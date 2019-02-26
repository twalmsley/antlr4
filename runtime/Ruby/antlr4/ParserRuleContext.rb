require '../antlr4/RuleContext'

class ParserRuleContext < RuleContext


  attr_accessor :children


#	public List<Integer> states

  attr_accessor :start
  attr_accessor :stop


  attr_accessor :exception

  def copyFrom(ctx)
    @parent = ctx.parent
    @invokingState = ctx.invokingState

    @start = ctx.start
    @stop = ctx.stop

# copy any error nodes to alt label node
    if (ctx.children != nil)
      @children = []
      # reset parent pointer for any error nodes
      ctx.children.each do |child|
        if (child.is_a ErrorNode)
          addChild(child)
        end
      end
    end
  end

  def initialize(parent, invokingStateNumber)
    super(parent, invokingStateNumber)
  end

# Double dispatch methods for listeners

  def enterRule(listener)
  end

  def exitRule(listener)
  end


  def addAnyChild(t)
    if (@children == nil)
      @children = []
    end
    @children << t
    return t
  end

  def addChild_ruleinvocation(ruleInvocation)
    return addAnyChild(ruleInvocation)
  end


  def addChild_terminalnode(t)
    t.setParent(self)
    return addAnyChild(t)
  end


  def addErrorNode(errorNode)
    errorNode.setParent(self)
    return addAnyChild(errorNode)
  end


  def removeLastChild()
    if (@children != nil)
      @children.delete_at(-1)
    end
  end


  def getParent()
    return super.getParent()
  end


  def getChild_at(i)
    return @children != nil && i >= 0 && i < @children.length ? @children[i] : nil
  end

  def getChild(ctxType, i)
    if (@children == nil || i < 0 || i >= @children.length)
      return nil
    end

    j = -1 # what element have we found with ctxType?
    @children.each do |o|
      if (ctxType.isInstance(o))
        j += 1
        if (j == i)
          return ctxType.cast(o)
        end
      end
    end
    return nil
  end

  def getToken(ttype, i)
    if (@children == nil || i < 0 || i >= @children.length)
      return nil
    end

    j = -1 # what token with ttype have we found?
    @children.each do |o|
      if (o.is_a? TerminalNode)
        tnode = o
        symbol = tnode.getSymbol()
        if (symbol.getType() == ttype)
          j += 1
          if (j == i)
            return tnode
          end
        end
      end
    end

    return nil
  end

  def getTokens(ttype)
    if (@children == nil)
      return []
    end

    tokens = nil
    @children.each do |o|
      if (o.is_a? TerminalNode)
        tnode = o
        symbol = tnode.getSymbol()
        if (symbol.getType() == ttype)
          if (tokens == nil)
            tokens = []
          end
          tokens << tnode
        end
      end
    end

    if (tokens == nil)
      return []
    end

    return tokens
  end

  def getRuleContext(ctxType, i)
    return getChild(ctxType, i)
  end

  def getRuleContexts(ctxType)
    if (@children == nil)
      return []
    end

    contexts = nil
    @children.each do |o|
      if (ctxType.isInstance(o))
        if (contexts == nil)
          contexts = []
        end

        contexts << ctxType.cast(o)
      end
    end

    if (contexts == nil)
      return []
    end

    return contexts
  end


  def getChildCount()
    return @children != nil ? @children.length : 0
  end


  def getSourceInterval()
    if (start == nil)
      return Interval.INVALID
    end
    if (stop == nil || @stop.getTokenIndex() < @start.getTokenIndex())
      return Interval.of(@start.getTokenIndex(), @start.getTokenIndex() - 1) # empty
    end
    return Interval.of(@start.getTokenIndex(), @stop.getTokenIndex())
  end


  def getStart()
    return @start
  end


  def getStop()
    return @stop
  end


  def toInfoString(recognizer)

    rules = recognizer.getRuleInvocationStack_2(self)
    rules.reverse!
    return "ParserRuleContext" + rules + "" +
        "start=" + start +
        ", stop=" + stop +
        'end'
  end

end

