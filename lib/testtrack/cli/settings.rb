require 'thor'
require 'fileutils'
require 'yaml'
require_relative 'clibase'

module TestTrack
	module CLI
		
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
	end
end