# I got the method_missing hit from http://www.goodercode.com/wp/convert-your-hash-keys-to-object-properties-in-ruby
class Hash
	def method_missing(name)
		return self[name] if key? name

		self.each do |key, value|
			return value if key.to_s.to_sym == name 
			super.method_mimssing name
		end
	end

	def respond_to?(symbol, include_all = false)
		return true if self.has_key?( symbol )
		super.respond_to? symbol, include_all
	end
end