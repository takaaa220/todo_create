require 'sinatra'
require 'sinatra/reloader' if development?
require 'json'

get "/" do
  "hello"
end

post "/payload" do
  "post"
end
