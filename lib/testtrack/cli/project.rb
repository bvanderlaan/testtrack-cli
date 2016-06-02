require 'thor'
require_relative 'clibase'
require_relative '../../testtrack-api'

module TestTrack
	module CLI

		class Project < CLIBaseWithGlobalOptions

			desc 'list', 'List all projects you have access to.'
			def list()
				auth()
				server_uri = get_server_uri()

				api = TestTrackApi.new(server_uri)

				say_status 'Ok', "Querying server for list of projects, please stand by...", :green
				begin
					projects = api.list_projects(@settings[:username], @settings[:password])
					say_status 'Ok', "Number of projects found: #{projects.count}", :green
					puts projects
				rescue InvalidURL, APIError, HTTPError => e
					say_status 'ERROR', e.message, :red
				end
			end

			map ls: :list
		end
	end
end