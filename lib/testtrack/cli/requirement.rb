require 'thor'
require_relative 'clibase'
require_relative '../../testtrack-api'
require_relative "../requirement"

module TestTrack
	module CLI

		class Requirement < CLIBaseWithGlobalOptions
			
			desc 'list [PROJECT NAME][REQUIREMENT ID]', 'List the information about the given requirement.'
			method_option :json, type: :boolean, aliases: ['-j', '-J' ], desc: 'Display the requirement information as a json string.'
			method_option :yaml, type: :boolean, aliases: ['-y', '-Y'], desc: 'Display the requirement information as a yaml string.'
			def list(project_name, requirement_id = 0)
				if requirement_id.to_i <= 0
					say_status 'ERROR', "The requirement id was not provided", :red if requirement_id.to_i == 0
					say_status 'ERROR', "The requirement id must been greater then zero", :red unless requirement_id.to_i >= 0
					return
				end

				auth()
				server_uri = get_server_uri()

				api = TestTrackApi.new( server_uri )
				say_status 'Ok', "Querying server for list of requirements, please stand by...", :green
				begin
					requirement = TestTrack::Requirement.new( api.list_requirement(requirement_id, project_name, @settings[:username], @settings[:password]) )
				rescue InvalidURL, APIError, HTTPError => e
					say_status 'ERROR', e.message, :red
				else
					say_status 'Ok', "Requirement found", :green

					puts requirement.to_json if options[:json]
					puts requirement.to_yaml if options[:yaml]
					puts requirement.to_s unless options[:json] or options[:yaml]
				end
			end	

			map ls: :list	
		end
	end
end