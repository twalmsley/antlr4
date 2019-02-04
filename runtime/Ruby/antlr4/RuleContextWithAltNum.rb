



















class RuleContextWithAltNum extends ParserRuleContext 
	public int altNum
	public RuleContextWithAltNum()  altNum = ATN.INVALID_ALT_NUMBER end

	public RuleContextWithAltNum(ParserRuleContext parent, int invokingStateNumber) 
		super(parent, invokingStateNumber)
	end
	 public int getAltNumber()  return altNum end
	 public void setAltNumber(int altNum)  this.altNum = altNum end
end
