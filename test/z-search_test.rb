ENV["RACK-ENV"] = "test"

require 'minitest/autorun'
require 'rack/test'
require 'fileutils'

require_relative "../z-search"

class ZSearchTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_homepage
    get "/"

    assert_equal 200, last_response.status
    assert_includes last_response.body, "Simple search"
    assert_includes last_response.body, "for tickets, organizations, and users"
  end

  def test_search_params_retention
    get "/", {:search => "ABC123", :category => "tickets"}
    assert_equal 200, last_response.status
    assert_includes last_response.body, "<option value='tickets' selected='selected'>Tickets</option>"
    assert_includes last_response.body, "<input name=\"search\" value='ABC123'"

    get "/", {:search => "OOOXXX", :category => "organizations"} 
    assert_equal 200, last_response.status
    assert_includes last_response.body, "<option value='organizations' selected='selected'>Organizations</option>"
    assert_includes last_response.body, "<input name=\"search\" value='OOOXXX'"

    get "/", {:search => "", :category => "users"}
    assert_equal 200, last_response.status
    assert_includes last_response.body, "<option value='users' selected='selected'>Users</option>"
    assert_includes last_response.body, "<input name=\"search\" value=''"
  end

  def test_search_int_fields
    get "/", {:search => "116", :category => "organizations"}

    assert_equal 200, last_response.status
    assert_includes last_response.body.delete(" \n"), '<divclass="col-md-2">_id</div><divclass="col-md-10"><strong>116</strong></div>'
  end

  def test_search_boolean_fields
    get "/", {:search => "true", :category => "tickets"}

    assert_equal 200, last_response.status
    assert_includes last_response.body.delete(" \n"), '<divclass="col-md-2">has_incidents</div><divclass="col-md-10"><strong>true</strong></div>'
  end

  def test_search_nested_field
    get "/", {:search => "Fulton", :category => "organizations"}

    assert_equal 200, last_response.status
    assert_includes last_response.body.delete(" \n"), '<divclass="col-md-10">["<strong>Fulton</strong>","West","Rodriguez","Farley"]</div>'
  end

  def test_search_string_case_insensitive
    get "/", {:search => "trinidad and tobago", :category => "users"}

    assert_equal 200, last_response.status
    assert_includes last_response.body, '<strong>Trinidad and Tobago</strong>'
  end

  def test_search_empty_values
    get "/", {:search => "", :category => "organizations"}

    assert_equal 200, last_response.status
    assert_includes last_response.body, '<div class="col-md-10"><strong></strong></div>'
  end

  def test_search_no_result
    get "/", {:search => "abc123456", :category => "users"}

    assert_equal 200, last_response.status
    assert_includes last_response.body, 'There is no record matching the search criteria'
  end

end