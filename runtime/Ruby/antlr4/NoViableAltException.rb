require '../antlr4/RecognitionException'


class NoViableAltException < RecognitionException
  attr_accessor :deadEndConfigs
  attr_accessor :startToken
end
