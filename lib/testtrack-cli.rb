require 'thor'
require 'fileutils'

module TestTrack
	class CLIBase < Thor
		LOGIN_AUTH_FILE = ".testtrack_auth"

	protected
		def auth()
			begin
				auth_from_file 
			rescue ArgumentError
				auth_from_prompt
			end
		end

		def auth_from_prompt()
			@username = ask("[Auth] User name: " )
			@password = ask("[Auth] Password: ", echo: false )
			puts "\n\n"
		end

		def auth_from_file()
			data = open(LOGIN_AUTH_FILE).read if !options[:force_login] && File.exists?(LOGIN_AUTH_FILE)
			parts = data.split(' ')

			raise ArgumentError if parts.count != 2

			@username = parts[0]
			@password = parts[1]
		end	
	end

	class Project < CLIBase

		desc 'list', 'List all projects you have access to.'
		def list()
			auth()

			puts "This has been a test..."
		end
	end

	class CLI < CLIBase
		include Thor::Actions

		class_option :force_login, type: :boolean, alias: '-l'

		desc 'login', "Stores your TestTrack username/password so you don't have to enter them each time."
		def login()
			auth_from_prompt()

			if yes?("[Auth] Do you want me to save your credentials?")
				create_file LOGIN_AUTH_FILE, "#{@username} #{@password}"
			end
		end

		desc "project [SUBCOMMAND] [ARGS]", "tbd"
		subcommand 'project', Project
	
	end
end