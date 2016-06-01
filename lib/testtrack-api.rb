require_relative "testtrack/version"
require 'savon'

module TestTrack
	class TestTrackApi
		def initialize(server)
			@client = Savon.client(wsdl: "http://#{server}/ttsoapcgi.wsdl", 
  						headers: { "Authentication" => "secret" },
  						filters: [:password] )

			# puts @client.operations
		end

		def list_projects(username, password)
			response = @client.call(:get_project_list, message: { username: "#{username}", password: "#{password}" } )
  			return response.body			
  		end
	end
end
