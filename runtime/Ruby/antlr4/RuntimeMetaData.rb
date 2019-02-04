




































class RuntimeMetaData 































	public static final String VERSION = "4.7.2"











	def self.getRuntimeVersion() 
		return VERSION
	end



























































	def self.checkVersion(String generatingToolVersion, compileTimeVersion) 
		String runtimeVersion = VERSION
		boolean runtimeConflictsWithGeneratingTool = false
		boolean runtimeConflictsWithCompileTimeTool = false

		if ( generatingToolVersion!=null ) 
			runtimeConflictsWithGeneratingTool =
				!runtimeVersion.equals(generatingToolVersion) &&
				!getMajorMinorVersion(runtimeVersion).equals(getMajorMinorVersion(generatingToolVersion))
		end

		runtimeConflictsWithCompileTimeTool =
			!runtimeVersion.equals(compileTimeVersion) &&
			!getMajorMinorVersion(runtimeVersion).equals(getMajorMinorVersion(compileTimeVersion))

		if ( runtimeConflictsWithGeneratingTool ) 
			System.err.printf("ANTLR Tool version %s used for code generation does not match the current runtime version %s",
							  generatingToolVersion, runtimeVersion)
		end
		if ( runtimeConflictsWithCompileTimeTool ) 
			System.err.printf("ANTLR Runtime version %s used for parser compilation does not match the current runtime version %s",
							  compileTimeVersion, runtimeVersion)
		end
	end










	def self.getMajorMinorVersion(String version) 
		int firstDot = version.indexOf('.')
		int secondDot = firstDot >= 0 ? version.indexOf('.', firstDot + 1) : -1
		int firstDash = version.indexOf('-')
		int referenceLength = version.length()
		if (secondDot >= 0) 
			referenceLength = Math.min(referenceLength, secondDot)
		end

		if (firstDash >= 0) 
			referenceLength = Math.min(referenceLength, firstDash)
		end

		return version.substring(0, referenceLength)
	end
end
