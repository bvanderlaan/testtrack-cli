require 'yaml'
require 'json'
require_relative "hash"

module TestTrack
	class Requirement

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
			puts "Requirement Id:\t #{@data.recordid}" if @data.respond_to? :recordid
			puts "Created:\t #{@data.date_time_created.strftime(date_time_format)}" if @data.respond_to? :date_time_created
			puts "Last Modified:\t #{@data.date_time_modified.strftime(date_time_format)}" if @data.respond_to? :date_time_modified
			puts "State:\t\t #{@data.state}" if @data.respond_to? :state
			puts "Type:\t\t #{@data.type}" if @data.respond_to? :type
			puts "Entered by:\t #{@data.entered_by}" if @data.respond_to? :entered_by
			puts "Story Points:\t #{@data.custom_field_list.item[4].value}"
			puts
			puts "\t#{@data.summary}" if @data.respond_to? :summary
			puts
			puts "\t#{@data.description}" if @data.respond_to? :description
			puts
		end
	end
end