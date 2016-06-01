require 'thor'
require 'fileutils'
require 'yaml'

module TestTrack
	class CLIBase < Thor
		TESTTRACK_SETTINGS_FILE = ".testtrack_settings"

		class_option :force_login, type: :boolean, aliases: '-l'
		class_option :force_connection, type: :boolean, aliases: '-c'

		def initialize(*args)
			super
			@settings = Hash.new
			@settings = YAML::load_file(TESTTRACK_SETTINGS_FILE) if File.exists?(TESTTRACK_SETTINGS_FILE)
		end

	protected
		def auth()
			auth_from_prompt unless !options[:force_login] and @settings.has_key?(:username) and @settings.has_key?(:password)
		end

		def auth_from_prompt()
			@settings[:username] = ask("[Auth] User name: " )
			@settings[:password] = ask("[Auth] Password: ", echo: false )
			puts "\n\n"
		end

		def get_server_uri
			get_server_uri_from_prompt unless !options[:force_connection] and @settings.has_key?(:servername) and @settings.has_key?(:serverport)
			return "#{@settings[:servername]}:#{@settings[:serverport]}"
		end

		def get_server_uri_from_prompt
			@settings[:servername] = ask("[Con] Server Name or IP: ")
			@settings[:serverport] = ask("[Con] Server Port: ")
			puts "\n\n"
		end

	end

	class Project < CLIBase

		desc 'list', 'List all projects you have access to.'
		def list()
			auth()
			server_uri = get_server_uri()

			puts "This has been a test...#{server_uri}"
		end
	end

	class CLI < CLIBase
		include Thor::Actions

		desc 'login', "Stores your TestTrack username/password so you don't have to enter them each time."
		def login()
			auth_from_prompt()

			if yes?("[Auth] Do you want me to save your credentials?")
				create_file TESTTRACK_SETTINGS_FILE, @settings.to_yaml
			end
		end

		desc "project [SUBCOMMAND] [ARGS]", "tbd"
		subcommand 'project', Project
	
	end
end