require 'thor'
require 'yaml'

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
	end
end