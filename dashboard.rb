require "./lib/geolocation"
require "sinatra/base"
require "json"
require "httparty"
require "pry"
require "dotenv"
Dotenv.load

class Dashboard < Sinatra::Base
  get("/") do
    @ip = request.ip
    @geolocation = Geolocation.new(@ip)

    latitude = @geolocation.latitude
    longitude = @geolocation.longitude
    weather_key = ENV["DARK_SKY_FORECAST_API_KEY"]

    url=("https://api.forecast.io/forecast/#{weather_key}/#{latitude},#{longitude}")

    response = HTTParty.get(url)
    @weather_data = JSON.parse(response.body)["currently"]

    events_key = ENV["GRACENOTE_API_KEY"]
    events_zip = @geolocation.zip
    date = Time.now.strftime("%Y-%m-%d")

    url=("http://data.tmsapi.com/v1.1/movies/showings?startDate=#{date}&zip=#{events_zip}&api_key=#{events_key}")

    response = HTTParty.get(url)
    @movies = JSON.parse(response.body)

    # binding.pry
    erb :dashboard
  end
end
