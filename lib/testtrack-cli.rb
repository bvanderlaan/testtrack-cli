require 'thor'
require 'fileutils'
require 'yaml'
require_relative 'testtrack-api'

module TestTrack
	class CLIBase < Thor
		include Thor::Actions

		TESTTRACK_SETTINGS_FILE = ".testtrack_settings"

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

		def save_settings
			create_file TESTTRACK_SETTINGS_FILE, @settings.to_yaml
		end

	end

	class Project < CLIBase

		class_option :force_login, type: :boolean, aliases: '-l'
		class_option :force_connection, type: :boolean, aliases: '-c'

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
			rescue InvalidURL, APIError => e
				say_status 'ERROR', e.message, :red
			end
		end

		map ls: :list
	end

	class Settings < CLIBase

		desc 'server', "Stores the server name and port so you don't have to enter them each time."
		def server()
			get_server_uri_from_prompt()
			save_settings()
		end

		desc 'login', "Stores your TestTrack username/password so you don't have to enter them each time."
		def login()
			auth_from_prompt()
			save_settings()
		end

		desc 'clear', "Clears stored settings."
		method_option :all, type: :boolean, aliases: '-a', desc: "Use this to clear all settings."
		def clear()
			@settings.clear if options[:all]

			@settings.each do |key, value|
				if yes?("[Settings] Do you want me to clear the #{key} from the store?")
					@settings.delete(key)
				end
			end

			save_settings
		end
	end

	class CLI < CLIBase
		
		desc 'settings [SUBCOMMAND] [ARGS]', "Manages gloabl settings."
		subcommand 'settings', Settings

		desc "project [SUBCOMMAND] [ARGS]", "Manages TestTrack projects."
		subcommand 'project', Project
	
	end
end