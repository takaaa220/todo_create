require 'sinatra'
require 'sinatra/reloader' if development?
require 'json'
require 'net/http'
require 'uri'
require 'pry'

get "/" do
  "hello"
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

  issue_url = "https://api.github.com/repos/#{repo_name}/issues"
  included_todo.each do |todo|
    # TODO: Parseをもっとちゃんとする
    todo = URI.decode(todo.gsub(/.*TODO: /, "")).force_encoding("UTF-8")

    uri = URI.parse(issue_url)
    request = Net::HTTP::Post.new(uri)
    request.basic_auth(ENV["GITID"], ENV["GITPASS"])

    request.body = JSON.dump( {
      title: todo,
      labels: ["TODO"]
    })
    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
  end
end
