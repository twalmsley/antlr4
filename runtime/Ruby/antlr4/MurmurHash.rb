











public final class MurmurHash 

	private static final int DEFAULT_SEED = 0






	def self.initialize() 
		return initialize(DEFAULT_SEED)
	end







	def self.initialize(int seed) 
		return seed
	end








	def self.update(int hash, int value) 
		final int c1 = 0xCC9E2D51
		final int c2 = 0x1B873593
		final int r1 = 15
		final int r2 = 13
		final int m = 5
		final int n = 0xE6546B64

		int k = value
		k = k * c1
		k = (k << r1) | (k >>> (32 - r1))
		k = k * c2

		hash = hash ^ k
		hash = (hash << r2) | (hash >>> (32 - r2))
		hash = hash * m + n

		return hash
	end








	def self.update(int hash, Object value) 
		return update(hash, value != null ? value.hashCode() : 0)
	end









	def self.finish(int hash, int numberOfWords) 
		hash = hash ^ (numberOfWords * 4)
		hash = hash ^ (hash >>> 16)
		hash = hash * 0x85EBCA6B
		hash = hash ^ (hash >>> 13)
		hash = hash * 0xC2B2AE35
		hash = hash ^ (hash >>> 16)
		return hash
	end










	public static <T> int hashCode( data, int seed) 
		int hash = initialize(seed)
		for (T value : data) 
			hash = update(hash, value)
		end

		hash = finish(hash, data.length)
		return hash
	end

	private MurmurHash() 
	end
end
