require 'yaml'
require 'json'
require_relative "hash"

module TestTrack
	class Defect

		def initialize(hash)
			@data = hash
		end

		def to_yaml
			@data.to_yaml
		end

		def to_json
			@data.to_json
		end

		def to_s
			date_time_format = "%a %B %d %Y, %I:%M:%S %p %Z"
			puts
			puts "Defect Id:\t #{@data.recordid}"
			puts "Created:\t #{@data.datetimecreated.strftime(date_time_format)}"
			puts "Last Modified:\t #{@data.datetimemodified.strftime(date_time_format)}"
			puts "State:\t\t #{@data.state}"
			puts "Priority:\t #{@data.priority}"
			puts "Severity:\t #{@data.severity}"
			puts "Type:\t\t #{@data.type}"
			puts "Product:\t #{@data.product}"
			puts "Component:\t #{@data.component}"
			puts "Found by:\t #{@data.enteredby}"
			puts
			puts "\t#{@data.summary}"
			puts
		end
	end
end