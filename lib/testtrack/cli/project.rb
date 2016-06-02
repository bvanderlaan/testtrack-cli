require 'thor'
require_relative 'clibase'
require_relative '../testtrack-api'

module TestTrack
	module CLI

		class Project < CLIBaseWithGlobalOptions

			desc 'list', 'List all projects you have access to.'
			long_desc <<-LONGDESC
				List all projects you have access to.

				Example:
					\x5\t> testtrack project list
					

				You can also use the short form of the root command:
					\x5\t> testtrack p list
					

				The list sub command also provides a short form:
					\x5\t> testtrack p ls

			LONGDESC
			def list()
				auth()
				server_uri = get_server_uri()

				api = TestTrackApi.new(server_uri)

				say_status 'Ok', "Querying server for list of projects, please stand by...", :green
				begin
					projects = api.list_projects(@settings[:username], @settings[:password])
				rescue InvalidURL, APIError, HTTPError => e
					say_status 'ERROR', e.message, :red
				else
					say_status 'Ok', "Number of projects found: #{projects.count}", :green
					puts projects
				end
			end

			map ls: :list
		end
	end
end