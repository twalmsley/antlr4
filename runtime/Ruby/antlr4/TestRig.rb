















class TestRig 
	def self.main(String[] args) 
		try 
			Class<?> testRigClass = Class.forName("org.antlr.v4.gui.TestRig")
			System.err.println("Warning: TestRig moved to org.antlr.v4.gui.TestRig calling automatically")
			try 
				Method mainMethod = testRigClass.getMethod("main", String[].class)
				mainMethod.invoke(null, (Object)args)
			end
			catch (Exception nsme) 
				System.err.println("Problems calling org.antlr.v4.gui.TestRig.main(args)")
			end
		end
		catch (ClassNotFoundException cnfe) 
			System.err.println("Use of TestRig now requires the use of the tool jar, antlr-4.X-complete.jar")
			System.err.println("Maven users need group ID org.antlr and artifact ID antlr4")
		end
	end
end
