class Trees


  def self.to_sTree_recog(t, recog = nil)
    ruleNames = recog != nil ? recog.getRuleNames() : nil
    ruleNamesList = ruleNames != nil ? ruleNames : nil
    return to_sTree_rulenames(t, ruleNamesList)
  end


  def self.to_sTree_rulenames(t, ruleNames)
    s = Utils.escapeWhitespace(getNodeText(t, ruleNames), false)
    if (t.getChildCount() == 0)
      return s
    end
    buf = ""
    buf << "("
    s = Utils.escapeWhitespace(getNodeText(t, ruleNames), false)
    buf << s
    buf << ' '
    i = 0
    while i < t.getChildCount()
      if (i > 0)
        buf << ' '
      end
      buf << toStringTree(t.getChild(i), ruleNames)
      i += 1
    end
    buf << ")"
    return buf
  end

  def self.getNodeText_recog(t, recog)
    ruleNames = recog != nil ? recog.getRuleNames() : nil
    ruleNamesList = ruleNames != nil ? ruleNames : nil
    return getNodeText(t, ruleNamesList)
  end

  def self.getNodeText_rulenames(t, ruleNames)
    if (ruleNames != nil)
      if (t.is_a? RuleContext)
        ruleIndex = t.getRuleContext().getRuleIndex()
        ruleName = ruleNames[ruleIndex]
        altNumber = t.getAltNumber()
        if (altNumber != ATN.INVALID_ALT_NUMBER)
          return ruleName + ":" + altNumber
        end
        return ruleName
      elsif (t.is_a? ErrorNode)
        return t.to_s()
      elsif (t.is_a? TerminalNode)
        symbol = t.getSymbol()
        if (symbol != nil)
          s = symbol.getText()
          return s
        end
      end
    end
    # no recog for rule names
    payload = t.getPayload()
    if (payload.is_a Token)
      return payload.getText()
    end
    return t.getPayload().to_s()
  end


  def self.getChildren(t)
    kids = []
    i = 0
    while i < t.getChildCount()
      kids << t.getChild(i)
      i += 1
    end

    return kids
  end


  def self.getAncestors(t)
    if (t.getParent() == nil)
      return []
    end
    ancestors = []
    t = t.getParent()
    while (t != nil)
      ancestors.unshift(t) # insert at start
      t = t.getParent()
    end
    return ancestors
  end


  def self.isAncestorOf(t, u)
    if (t == nil || u == nil || t.getParent() == nil)
      return false
    end
    p = u.getParent()
    while (p != nil)
      if (t == p)
        return true
      end
      p = p.getParent()
    end
    return false
  end

  def self.findAllTokenNodes(t, ttype)
    return findAllNodes(t, ttype, true)
  end

  def self.findAllRuleNodes(t, ruleIndex)
    return findAllNodes(t, ruleIndex, false)
  end

  def self.findAllNodes(t, index, findTokens)
    nodes = []
    _findAllNodes(t, index, findTokens, nodes)
    return nodes
  end

  def self._findAllNodes(t, index, findTokens, nodes)

    # check this node (the root) first
    if (findTokens && t.is_a?(TerminalNode))
      tnode = t
      if (tnode.getSymbol().getType() == index)
        nodes.add(t)
      end
    elsif (!findTokens && t.is_a(ParserRuleContext))
      ctx = t
      if (ctx.getRuleIndex() == index)
        nodes.push(t)
      end
    end
    # check children
    i = 0
    while i < t.getChildCount()
      _findAllNodes(t.getChild(i), index, findTokens, nodes)
      i += 1
    end
  end


  def self.getDescendants(t)
    nodes = []
    nodes.push(t)

    n = t.getChildCount()
    i = 0
    while i < n
      nodes.addAll(getDescendants(t.getChild(i)))
      i += 1
    end
    return nodes
  end


  def self.descendants(t)
    return getDescendants(t)
  end


  def self.getRootOfSubtreeEnclosingRegion(t, startTokenIndex, stopTokenIndex)

    n = t.getChildCount()
    i = 0
    while i < n
      ParseTree child = t.getChild(i)
      ParserRuleContext r = getRootOfSubtreeEnclosingRegion(child, startTokenIndex, stopTokenIndex)
      if (r != nil)
        return r
      end
      i += 1
    end
    if (t.is_a? ParserRuleContext)
      r = t
      if (startTokenIndex >= r.getStart().getTokenIndex() && # is range fully contained in t?
          (r.getStop() == nil || stopTokenIndex <= r.getStop().getTokenIndex()))

        # note: r.getStop()==nil likely implies that we bailed out of parser and there's nothing to the right
        return r
      end
    end
    return nil
  end


  def self.stripChildrenOutOfRange(t, root, startIndex, stopIndex)

    if (t == nil)
      return
    end

    i = 0
    while i < t.getChildCount()
      child = t.getChild(i)
      range = child.getSourceInterval()
      if (child.is_a? ParserRuleContext && (range.b < startIndex || range.a > stopIndex))
        if (isAncestorOf(child, root)) # replace only if subtree doesn't have displayed root
          abbrev = CommonToken.new(Token::INVALID_TYPE, "...")
          t.children.set(i, TerminalNodeImpl.new(abbrev))
        end
      end
    end
  end


  def self.findNodeSuchThat(t, pred)
    if (pred.test(t))
      return t
    end

    if (t == nil)
      return nil
    end

    n = t.getChildCount()
    i = 0
    while i < n
      u = findNodeSuchThat(t.getChild(i), pred)
      if (u != nil)
        return u
      end
      i += 1
    end
    return nil
  end

end
