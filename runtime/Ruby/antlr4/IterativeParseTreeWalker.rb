class IterativeParseTreeWalker
  extends ParseTreeWalker


  public void walk(ParseTreeListener listener, ParseTree t)

  final Deque < ParseTree > nodeStack = new ArrayDeque < ParseTree > ()
  final IntegerStack indexStack = new IntegerStack()

  ParseTree currentNode = t
  int currentIndex = 0

  while (currentNode != null)

    # pre-order visit
    if (currentNode instanceof ErrorNode)
      listener.visitErrorNode((ErrorNode) currentNode)
    end
    else
    if (currentNode instanceof TerminalNode)
      listener.visitTerminal((TerminalNode) currentNode)
    end
    else
    final RuleNode r = (RuleNode) currentNode
    enterRule(listener, r)
  end

  # Move down to first child, if exists
  if (currentNode.getChildCount() > 0)
    nodeStack.push(currentNode)
    indexStack.push(currentIndex)
    currentIndex = 0
    currentNode = currentNode.getChild(0)
    continue
  end

  # No child nodes, so walk tree
  do

  # post-order visit
  if (currentNode instanceof RuleNode)
    exitRule(listener, (RuleNode) currentNode)
  end

  # No parent, so no siblings
  if (nodeStack.isEmpty())
    currentNode = null
    currentIndex = 0
    break
  end

  # Move to next sibling if possible
  currentNode = nodeStack.peek().getChild(++currentIndex)
  if (currentNode != null)
    break
  end

  # No next, sibling, so move up
  currentNode = nodeStack.pop()
  currentIndex = indexStack.pop()

end while (currentNode != null)
end
end
end
