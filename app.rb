require 'json'
require 'net/http'
require 'net/https'
require 'uri'
require 'rubygems'
require 'twilio-ruby'
require 'sinatra'

IMGUR_CLIENT_ID = ENV["IMGUR_CLIENT_ID"] or raise StandardError.new("Need IMGUR_CLIENT_ID env var")
uri = URI.parse("https://api.imgur.com/3/image")

post '/mms' do
	urls = []

	params["NumMedia"].to_i.times do |i|
		image_url = params["MediaUrl#{i}"]

		https = Net::HTTP.new(uri.host,uri.port)
		https.use_ssl = true
		req = Net::HTTP::Post.new(uri.path)
		req.set_form_data({"image" => image_url})
		req.add_field("Authorization", "Client-ID #{IMGUR_CLIENT_ID}")

		res = https.request(req)

		body = JSON.parse(res.body)

		if body["success"]
			urls << body["data"]["link"]
		end
	end

	twiml = Twilio::TwiML::Response.new do |r|
		r.Message "#{urls.join(', ')}"
	end
	twiml.text
end
