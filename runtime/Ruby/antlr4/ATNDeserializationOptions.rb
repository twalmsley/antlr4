class ATNDeserializationOptions
  @@defaultOptions = ATNDeserializationOptions.new

  def initialize(readOnly = true, options = nil)
    @readOnly = readOnly
    if options != nil
      @verifyATN = options.verifyATN
      @generateRuleBypassTransitions = options.generateRuleBypassTransitions
    else
      @verifyATN = true
      @generateRuleBypassTransitions = false
    end

  end


  def self.getDefaultOptions
    return @@defaultOptions
  end

  def isReadOnly
    return @readOnly
  end

  def makeReadOnly
    @readOnly = true
  end

  def isVerifyATN()
    return @verifyATN
  end

  def setVerifyATN(verifyATN)
    throwIfReadOnly
    @verifyATN = verifyATN
  end

  def isGenerateRuleBypassTransitions()
    return @generateRuleBypassTransitions
  end

  def setGenerateRuleBypassTransitions(generateRuleBypassTransitions)
    throwIfReadOnly
    @generateRuleBypassTransitions = generateRuleBypassTransitions
  end

  def throwIfReadOnly
    if (isReadOnly())
      raise IllegalStateException, "The object is read only."
    end
  end
end
