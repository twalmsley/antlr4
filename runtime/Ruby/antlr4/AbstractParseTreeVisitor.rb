class AbstractParseTreeVisitor

  def visit(tree)
    return tree.accept(self)
  end

  def visitChildren(node)
    result = defaultResult
    n = node.getChildCount
    i = 0
    while i < n
      if !shouldVisitNextChild(node, result)
        break
      end

      c = node.getChild(i)
      childResult = c.accept(this)
      result = aggregateResult(result, childResult)

      i += 1
    end

    return result
  end

  def visitTerminal(node)
    return defaultResult
  end

  def visitErrorNode(node)
    return defaultResult
  end

  def defaultResult()
    return nil
  end

  def aggregateResult(aggregate, nextResult)
    return nextResult
  end

  def shouldVisitNextChild(node, currentResult)
    return true
  end

end
