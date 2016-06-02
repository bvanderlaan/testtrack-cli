require 'thor'
require 'fileutils'
require 'yaml'
require 'json'
require_relative 'testtrack-api'
require_relative "testtrack/hash"

module TestTrack
	module CLI
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
		end

		class CLIBaseWithGlobalOptions < CLIBase
			class_option :force_login, type: :boolean, aliases: '-l'
			class_option :force_connection, type: :boolean, aliases: '-c'
		end

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

			private
			def save_settings
				create_file TESTTRACK_SETTINGS_FILE, @settings.to_yaml
			end
		end

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
					defect = api.list_defect(defect_id, project_name, @settings[:username], @settings[:password])
				rescue InvalidURL, APIError, HTTPError => e
					say_status 'ERROR', e.message, :red
				end

				say_status 'Ok', "Defect found", :green

				if options[:json]
					puts defect.to_json
				elsif options[:yaml]
					puts defect.to_yaml
				else
					date_time_format = "%a %B %d %Y, %I:%M:%S %p %Z"
					puts
					puts "Defect Id:\t #{defect.recordid}"
					puts "Created:\t #{defect.datetimecreated.strftime(date_time_format)}"
					puts "Last Modified:\t #{defect.datetimemodified.strftime(date_time_format)}"
					puts "State:\t\t #{defect.state}"
					puts "Priority:\t #{defect.priority}"
					puts "Severity:\t #{defect.severity}"
					puts "Type:\t\t #{defect.type}"
					puts "Product:\t #{defect.product}"
					puts "Component:\t #{defect.component}"
					puts "Found by:\t #{defect.enteredby}"
					puts
					puts "\t#{defect.summary}"
					puts
				end
			end	

			map ls: :list	
		end

		class CLI < CLIBase
			
			desc 'settings [SUBCOMMAND] [ARGS]', "Manages gloabl settings."
			subcommand 'settings', Settings

			desc "project [SUBCOMMAND] [ARGS]", "Manages TestTrack projects."
			subcommand 'project', Project

			desc "defect [SUBCOMMAND] [ARGS]", "Manages TestTrack defects."
			subcommand 'defect', Defect
		
		end
	end
end