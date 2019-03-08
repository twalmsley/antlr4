require '../antlr4/DFASerializer'

class LexerDFASerializer < DFASerializer
  def initialize(dfa)
    initFromVocabulary(dfa, VocabularyImpl::EMPTY_VOCABULARY)
  end


  def getEdgeLabel(i)
    "'" << i.to_s << "'"
  end
end
