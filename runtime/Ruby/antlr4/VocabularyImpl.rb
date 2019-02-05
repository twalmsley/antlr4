require '../../antlr4/runtime/Ruby/antlr4/Vocabulary'

class VocabularyImpl < Vocabulary
  @@EMPTY_NAMES = []

  def initialize(literalNames, symbolicNames, displayNames = nil)
    @literalNames = literalNames != nil ? literalNames : @@EMPTY_NAMES
    @symbolicNames = symbolicNames != nil ? symbolicNames : @@EMPTY_NAMES
    @displayNames = displayNames != nil ? displayNames : @@EMPTY_NAMES
# See note here on -1 part: https:#github.com/antlr/antlr4/pull/1146
    @maxTokenType = [@displayNames.length, @literalNames.length, @symbolicNames.length].max - 1
  end

  EMPTY_VOCABULARY = VocabularyImpl.new(@@EMPTY_NAMES, @@EMPTY_NAMES, @@EMPTY_NAMES)


  def fromTokenNames(tokenNames)
    if (tokenNames == nil || tokenNames.length == 0)
      return EMPTY_VOCABULARY
    end

    @literalNames = Array.new(tokenNames)
    @symbolicNames = Array.new(tokenNames)
    i = 0
    while i < tokenNames.length
      tokenName = tokenNames[i]
      if (tokenName == nil)
        i += 1
        next
      end

      if (!tokenName.isEmpty())
        firstChar = tokenName.charAt(0)
        if (firstChar == '\'')
          @symbolicNames[i] = nil
          i += 1
          next
        elsif (Character.isUpperCase(firstChar))
          @literalNames[i] = nil
          i += 1
          next
        end
      end

      # wasn't a literal or symbolic name
      @literalNames[i] = nil
      @symbolicNames[i] = nil
      i += 1
    end

    return VocabularyImpl.new(@literalNames, @symbolicNames, tokenNames)
  end


  def getMaxTokenType()
    return @maxTokenType
  end


  def getLiteralName(tokenType)
    if (tokenType >= 0 && tokenType < @literalNames.length)
      return @literalNames[tokenType]
    end

    return nil
  end


  def getSymbolicName(tokenType)
    if (tokenType >= 0 && tokenType < @symbolicNames.length)
      return @symbolicNames[tokenType]
    end

    if (tokenType == Token.EOF)
      return "EOF"
    end

    return nil
  end


  def getDisplayName(tokenType)
    if (tokenType >= 0 && tokenType < @displayNames.length)
      displayName = @displayNames[tokenType]
      if (displayName != nil)
        return displayName
      end
    end

    literalName = getLiteralName(tokenType)
    if (literalName != nil)
      return literalName
    end

    symbolicName = getSymbolicName(tokenType)
    if (symbolicName != nil)
      return symbolicName
    end

    return Integer.to_s(tokenType)
  end
end
