require 'sinatra'
require 'sinatra/reloader' if development?
require 'json'

helpers do
  def bold_matched_keyword(txt, keyword)
    if is_a_matching_field(txt, keyword)
      txt_in_str = txt.to_s
      matched_keyword_begin_index = txt_in_str.downcase.index(keyword.downcase)
      matched_keyword_end_index = matched_keyword_begin_index + keyword.length
      new_txt = txt_in_str.insert(matched_keyword_end_index, '</strong>')
      new_txt = new_txt.insert(matched_keyword_begin_index, '<strong>')
      new_txt
    else
      txt
    end
  end

  def select_previously_selected_category(category)
    if params[:category] && params[:category] == category
      "<option value='#{category}' selected='selected'>#{category.capitalize}</option>"
    else
      "<option value='#{category}'>#{category.capitalize}</option>"
    end
  end
end

def is_a_matching_field(field, keyword)
  field.to_s.downcase.include? keyword.downcase
end

def data_path
  data_path = File.expand_path("../data", __FILE__)
end

def parse_json(directory_path, filename)
  file_path = File.join(directory_path, filename)
  raw_content = File.read(file_path)
  JSON.parse(raw_content)
end

def get_collections(category)
  parse_json(data_path, "#{category}.json")
end

def process_record(record)
  record.values.flatten.map{|field| downcase_string_field(field)}
end

def downcase_string_field(field)
  if field.is_a? String
    field.downcase
  else
    field.to_s
  end
end

get "/" do
  if params[:category]
    keyword = params[:search]
    @results = get_collections(params[:category]).select {|record| process_record(record).include? keyword.downcase }
    if @results.empty?
      session[:message] = "There is no record matching the search criteria."
    end
    erb :index
  else
    erb :home
  end 
end
