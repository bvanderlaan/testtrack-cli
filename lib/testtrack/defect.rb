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
			puts "Defect Id:\t #{@data.recordid}" if @data.respond_to? :recordid
			puts "Created:\t #{@data.datetimecreated.strftime(date_time_format)}" if @data.respond_to? :datetimecreated
			puts "Last Modified:\t #{@data.datetimemodified.strftime(date_time_format)}" if @data.respond_to? :datetimemodified
			puts "State:\t\t #{@data.state}" if @data.respond_to? :state
			puts "Priority:\t #{@data.priority}" if @data.respond_to? :priority
			puts "Severity:\t #{@data.severity}" if @data.respond_to? :severity
			puts "Type:\t\t #{@data.type}" if @data.respond_to? :type
			puts "Product:\t #{@data.product}" if @data.respond_to? :product
			puts "Component:\t #{@data.component}" if @data.respond_to? :component
			puts "Found by:\t #{@data.enteredby}" if @data.respond_to? :enteredby
			puts "Found in:\t #{@data.custom_field_list.item[0].value}"
			puts "Found on:\t #{@data.custom_field_list.item[1].value}"
			puts "Story Points:\t #{@data.custom_field_list.item[5].value}"
			puts "Fix for:\t #{@data.custom_field_list.item[9].value}"
			puts
			puts "\t#{@data.summary}" if @data.respond_to? :summary
			puts
		end
	end
end