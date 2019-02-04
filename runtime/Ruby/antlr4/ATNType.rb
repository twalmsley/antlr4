class ATNType

  LEXER = 0
  PARSER = 1

  @@values = [LEXER, PARSER]

  def self.values
    @@values
  end
end
