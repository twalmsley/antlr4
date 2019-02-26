require '../antlr4/Integer'

class DFASerializer

  def initialize(dfa, vocabulary)
    @dfa = dfa
    @vocabulary = vocabulary
  end


  def to_s()
    if (@dfa.s0 == nil)
      return nil
    end
    buf = ""
    states = @dfa.getStates()
    states.each do |s|
      n = 0
      if (s.edges != nil)
        n = s.edges.length
      end
      i = 0
      while i < n
        t = s.edges[i]
        if (t != nil && t.stateNumber != Integer::MAX)
          buf << getStateString(s)
          label = getEdgeLabel(i)
          buf << "-" << label << "->" << getStateString(t) << '\n'
        end
        i += 1
      end
    end

    output = buf
    if (output.length() == 0)
      return nil
    end
    #return Utils.sortLinesInString(output)
    return output
  end

  def getEdgeLabel(i)
    return @vocabulary.getDisplayName(i - 1)
  end


  def getStateString(s)
    n = s.stateNumber
    baseStateStr = (s.isAcceptState ? ":" : "") << "s" << n.to_s << (s.requiresFullContext ? "^" : "")
    if (s.isAcceptState)
      if (s.predicates != nil)
        preds = ""
        s.predicates.each do |p|
          preds << p.to_s
        end

        return baseStateStr << "=>" << preds
      else
        return baseStateStr << "=>" << @vocabulary.getSymbolicName(s.prediction)
      end
    else
      return baseStateStr
    end
  end
end
