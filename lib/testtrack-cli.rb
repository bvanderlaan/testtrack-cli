require 'thor'
require_relative 'testtrack/cli/clibase'
require_relative 'testtrack/cli/settings'
require_relative 'testtrack/cli/project'
require_relative 'testtrack/cli/defect'
require_relative 'testtrack/cli/requirement'
require_relative 'testtrack-api'

module TestTrack
	module CLI

		class CLI < CLIBase
			
			desc 'settings [SUBCOMMAND] [ARGS]', "Manages gloabl settings."
			subcommand 'settings', Settings

			desc "project [SUBCOMMAND] [ARGS]", "Manages TestTrack projects."
			subcommand 'project', Project

			desc "defect [SUBCOMMAND] [ARGS]", "Manages TestTrack defects."
			subcommand 'defect', Defect

			desc "requirement [SUBCOMMAND] [ARGS]", "Manages TestTrack requirements."
			subcommand 'requirement', Requirement
		
		end
	end
end