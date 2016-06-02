require 'thor'
require_relative 'clibase'
require_relative '../../testtrack-api'
require_relative "../defect"

module TestTrack
	module CLI

		class Defect < CLIBaseWithGlobalOptions
			
			desc 'list [PROJECT NAME][DEFECT ID]', 'List the information about the given defect.'
			method_option :json, type: :boolean, aliases: '-j', desc: 'Display the defect information as a json string.'
			method_option :yaml, type: :boolean, aliases: '-y', desc: 'Display the defect information as a yaml string.'
			def list(project_name, defect_id = 0)
				if defect_id.to_i <= 0
					say_status 'ERROR', "The defect id was not provided", :red if defect_id.to_i == 0
					say_status 'ERROR', "The defect id must been greater then zero", :red unless defect_id.to_i >= 0
					return
				end

				auth()
				server_uri = get_server_uri()

				api = TestTrackApi.new( server_uri )
				say_status 'Ok', "Querying server for list of defects, please stand by...", :green
				begin
					defect = TestTrack::Defect.new( api.list_defect(defect_id, project_name, @settings[:username], @settings[:password]) )
				rescue InvalidURL, APIError, HTTPError => e
					say_status 'ERROR', e.message, :red
				end

				say_status 'Ok', "Defect found", :green

				puts defect.to_json if options[:json]
				puts defect.to_yaml if options[:yaml]
				puts defect.to_s unless options[:json] or options[:yaml]
			end	

			map ls: :list	
		end
	end
end