require_relative "testtrack/version"
require_relative "testtrack/exceptions"
require 'savon'

module TestTrack
	class TestTrackApi
		def initialize(server)
			@wsdl_url = "http://#{server}/ttsoapcgi.wsdl"
			@client = Savon.client(wsdl: @wsdl_url, 
  						headers: { "Authentication" => "secret" },
  						filters: [:password] )

			# puts @client.operations
		end

		def list_projects(username, password)
			begin
				response = @client.call(:get_project_list, message: { username: "#{username}", password: "#{password}" } )
			rescue SocketError
				raise InvalidURL, "Can not find WSDL with url [#{@wsdl_url}]"
			rescue Savon::SOAPFault => error
				raise APIError, error.to_hash[:fault][:faultstring]
			end

  			return response.body			
  		end
	end
end
