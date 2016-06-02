require 'thor'
require_relative 'clibase'
require_relative '../testtrack-api'
require_relative "../defect"

module TestTrack
	module CLI

		class Defect < CLIBaseWithGlobalOptions
			
			desc 'list [PROJECT NAME][DEFECT ID]', 'List the information about the given defect.'
			long_desc <<-LONGDESC
				List the information about the given defect. The information will be printed to the terminal in a human friendly format.

				With the --json flag the information will be printed to the terminal as a JSON string. The --json flag has a short form that can be used: '-j' or '-J'

				With the --yaml flag the information will be printed to the terminal as a YAML stirng. The --yaml flag has a short form that can be used: '-y' or '-Y'

				Example:
					\x5\t> testtrack defect list MyProject 42
					\x5\t> testtrack defect list MyProject 42 -j
					\x5\t> testtrack defect list MyProject 42 -Y


				You can also use the short form of the root command:
					\x5\t> testtrack d list MyProject 42
					\x5\t> testtrack d list MyProject 42 -j
					\x5\t> testtrack d list MyProject 42 -Y


				The list sub command also provides a short form:
					\x5\t> testtrack defect ls MyProject 42 -J
					\x5\t> testtrack d ls MyProject 42

			LONGDESC
			method_option :json, type: :boolean, aliases: ['-j', '-J' ], desc: 'Display the defect information as a json string.'
			method_option :yaml, type: :boolean, aliases: ['-y', '-Y'], desc: 'Display the defect information as a yaml string.'
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
				else
					say_status 'Ok', "Defect found", :green

					puts defect.to_json if options[:json]
					puts defect.to_yaml if options[:yaml]
					puts defect.to_s unless options[:json] or options[:yaml]
				end
			end	

			map ls: :list	
		end
	end
end