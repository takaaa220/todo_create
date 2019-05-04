require 'sinatra'
require 'sinatra/reloader' if development?
require 'json'

get "/" do
  "hello"
end

post "/payload" do
  p request.body.read
end
