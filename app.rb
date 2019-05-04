require 'sinatra'
require 'sinatra/reloader' if development?
require 'json'
require 'net/http'
require 'uri'
require 'pry'

get "/" do
  body = { "compare" => "https://github.com/takaaa220/todo_create/compare/6114b38066c4...89569a6ffb3c" }
  diff_url = body["compare"] + ".diff"
  uri = URI.parse(diff_url)
  response_body = Net::HTTP.get_response(uri).body

  added_diff = response_body.split("\n").select do |line|
    line[0] == "+" && line[1] != "+" && line[2] != "+"
  end

  included_todo = added_diff.select { |diff| diff.include?("TODO: ") }

  included_todo.map do |todo|
    included_todo.gsub(/.*TODO: /, "")
  end
end

# TODO: 変更しましょう
post "/payload" do
  body = JSON.parse(params[:payload])
  diff_url = body["compare"] + ".diff"
  uri = URI.parse(diff_url)
  response_body = Net::HTTP.get_response(uri).body

  added_diff = response_body.split("\n").select do |line|
    line[0] == "+" && line[1] != "+" && line[2] != "+"
  end

  binding.pry

  included_todo = added_diff.select { |diff| diff.include?("TODO: ") }

  todos = included_todo.map do |todo|
    URI.decode(todo.gsub(/.*TODO: /, ""))
  end

  # TODO: Issue作成する
  p todos
end
