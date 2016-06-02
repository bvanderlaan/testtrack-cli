require 'thor'
require 'fileutils'
require 'yaml'
require_relative 'clibase'

module TestTrack
	module CLI
		
		class Settings < CLIBase

			desc 'server', "Stores the server name and port so you don't have to enter them each time."
			long_desc <<-LONGDESC
				Stores the server name and port so you don't have to enter them each time.

				Example:
					\x5\t> testtrack settings server
					

				You can also use the short form of the root command:
					\x5\t> testtrack s server

			LONGDESC
			def server()
				get_server_uri_from_prompt()
				save_settings()
			end

			desc 'login', "Stores your TestTrack username/password so you don't have to enter them each time."
			long_desc <<-LONGDESC
				Stores your TestTrack username/password so you don't have to enter them each time.

				Example:
					\x5\t> testtrack settings login
					

				You can also use the short form of the root command:
					\x5\t> testtrack s login

			LONGDESC
			def login()
				auth_from_prompt()
				save_settings()
			end

			desc 'clear', "Clears stored settings."
			long_desc <<-LONGDESC
				Clears stored settings. You will be asked for each stored setting if you want to clear it. This way you can clear only the setting you want to clear.

				If you want to clear all stored settings you can use the --all flag. This flag has a short form you can use: '-a' or '-A'

				Example:
                    \x5\t> testtrack settings clear
                    \x5\t> testtrack settings clear -a
                    \x5\t> testtrack settings clear --all
					

				You can also use the short form of the root command:
					\x5\t> testtrack s clear
					\x5\t> testtrack s clear --all
					\x5\t> testtrack s clear -A

			LONGDESC
			method_option :all, type: :boolean, aliases: ['-a','-A'], desc: "Use this to clear all settings."
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