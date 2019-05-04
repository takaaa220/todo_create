require 'sinatra'
require 'sinatra/reloader' if development?
require 'json'
require 'net/http'
require 'uri'

get "/" do
  "hello"
end

post "/payload" do
  body = JSON.parse(params[:payload])
  diff_url = body["compare"] + ".diff"
  uri = URI.parse(diff_url)
  response_body = NET::HTTP.get_response(uri).body

  added_diff = response_body.split("\n").select do |line|
    line[0] == "+" && line[1] != "+" && line[2] != "+"
  end

  included_todo = added_diff.select { |diff| diff.include?("TODO: ") }

  included_todo.each do |todo|
    p todo
  end
end
