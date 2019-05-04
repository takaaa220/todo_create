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
  repo_name = body["repository"]["full_name"]

  diff_url = body["compare"] + ".diff"
  uri = URI.parse(diff_url)
  response_body = Net::HTTP.get_response(uri).body

  added_diff = response_body.split("\n").select do |line|
    line[0] == "+" && line[1] != "+" && line[2] != "+"
  end

  included_todo = added_diff.select { |diff| diff.include?("TODO: ") }

  issues = included_todo.map do |todo|
    todo = URI.decode(todo.gsub(/.*TODO: /, "")).force_encoding("UTF-8")

    {
      title: todo,
      labels: ["TODO"]
    }
  end

  issue_url = "https://api.github.com/repos/#{repo_name}/issues"
  uri = URI.parse(issue_url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  req = Net::HTTP::Post.new(uri.path)

  # TODO: 認証必要あり？
  issues.each do |issue|
    req.set_form_data(issue)
    http.request(req)
  end
end
