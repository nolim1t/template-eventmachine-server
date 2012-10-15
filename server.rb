# Template web server for ruby eventmachine
# Used for tasks which can be done in Ruby only

require 'eventmachine'
require 'em-http-server'
require 'cgi'
require 'active_support/all'

class HTTPHandler < EM::HttpServer::Server
	def process_http_request
		puts @http_request_uri
		puts @http_request_method

		response = EM::DelegatedHttpResponse.new(self)
		status = 404
		body = 'Not found'
		content_type = 'text/plain'
		
		keys = []
		vals = []
		has_parameters = false
		if @http_query_string != nil and @http_request_method == "GET"
			parse_request = @http_query_string.split('&')
			if parse_request.length > 0 then
				parse_request.each {|param|
					kv_array = param.split('=')
					keys.push kv_array[0]
					vals.push CGI::unescape(kv_array[1])
				}
			end
		elsif @http_content != nil and @http_request_method == "POST"
			parse_request = @http_content.split('&')
			if parse_request.length > 0 then
				parse_request.each {|param|
					kv_array = param.split('=')
					keys.push kv_array[0]
					vals.push CGI::unescape(kv_array[1])
				}
			end			
		end
		if keys.length >= 1
			# Must be matching pairs of keys otherwise lets ignore it
			# There must be a better way?
			if keys.length == vals.length
				has_parameters = true
				puts "Keys: #{keys.inspect} Vals: #{vals.inspect}"
			end
		end

		# TODO: check @http_request_uri for the URL and then check other stuff
		# @http_protocol for http or https
		# @http_request_method for POST or GET
		# @http_content for body content

		#####################
		# status, content_type, and body should be re-written or else it will be 
		# 404 not found
		#####################
		response.status = status
		response.content_type content_type
		response.content = body
		response.send_response
	end
end


#####################
# Lets start it
#####################
if ENV['PORT'] != nil
	port = ENV['PORT'].to_i
else
	port = 8088
end

EM::run do 
	puts 'Starting server on port ' + port.to_s
	EM::start_server('0.0.0.0', port, HTTPHandler)
end