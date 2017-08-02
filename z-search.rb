require 'sinatra'
require 'sinatra/reloader'
require 'json'

helpers do
  def bold_matched_keyword(txt, keyword)
    new_txt = txt.to_s.gsub(keyword, "<strong>#{keyword}</strong>")
    new_txt
  end
end

def data_path
  data_path = File.expand_path("../data", __FILE__)
end

def parse_json(directory_path, filename)
  file_path = File.join(directory_path, filename)
  raw_content = File.read(file_path)
  JSON.parse(raw_content)
end

def tickets
  parse_json(data_path, "tickets.json")
end

def users
  parse_json(data_path, "users.json")
end

def organizations
  parse_json(data_path, "organizations.json")
end

get "/" do
  @tickets = tickets.select {|ticket| ticket.values.flatten.include? params[:search]}
  erb :index
end