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
			response = invoke_api_method( :get_project_list, { username: "#{username}", password: "#{password}" } )

			projects = Array.new
  			response.body[:get_project_list_response][:p_proj_list][:item].each do |item|
  				item.each do |key, value|
  					projects.push( value[:name] ) if key == :database
  				end
  			end

  			return projects
  		end

  		def list_defect(defect_id, project_name, username, password)
  			login(project_name, username, password)

  			begin
  				response = invoke_api_method( :get_defect_by_record_id, { cookie: @cookie, recordID: defect_id } )
  			ensure 
  				logoff()
  			end

			return response.body[:get_defect_by_record_id_response][:p_defect]
  		end

  		def list_requirement(requirement_id, project_name, username, password)
  			login(project_name, username, password)

  			begin
  				response = invoke_api_method( :get_requirement_by_record_id, { cookie: @cookie, recordID: requirement_id } )
  			ensure 
  				logoff()
  			end

			return response.body[:get_requirement_by_record_id_response][:p_requirement]
  		end

  	private

  		def login(project_name, username, password)
  			response = invoke_api_method( :database_logon, { dbname: project_name, username: username, password: password } )
  		    @cookie = response.body[:database_logon_response][:cookie]
  		end

  		def logoff()
  			invoke_api_method( :database_logoff, { cookie: @cookie } ) unless @cookie == nil 			
  		end

  		def invoke_api_method(method, params)
  			begin
  				response = @client.call(method, message: params)
			rescue SocketError
				raise InvalidURL, "Can not find WSDL with url [#{@wsdl_url}]"
			rescue Savon::SOAPFault => error
				raise APIError, error.to_hash[:fault][:faultstring]
			rescue Savon::HTTPError => error
				raise TestTrack::HTTPError, error.http.code
			end  

			return response
  		end
	end
end
