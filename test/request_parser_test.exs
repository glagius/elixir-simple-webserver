defmodule RequestParserTest do
  use ExUnit.Case
  doctest RequestParser

  test "Must parse GET requests" do
    assert RequestParser.parse("GET / HTTP/1.1") ==
             {:GET, "/", %{"file" => "static/pages/home/index.html"}}

    assert RequestParser.parse("GET /about HTTP/1.1") ==
             {:GET, "/about", %{"file" => "static/pages/about/index.html"}}

    # assert RequestParser.parse("GET /api/v1/user HTTP/1.1") == {:GET, "/api/v1/user", %{}}

    # assert RequestParser.parse("GET /api/v1/user/23?name=Eldar&pass=1234 HTTP/1.1") ==
    #          {:GET, "/api/v1/user/23", %{"name" => "Eldar", "pass" => "1234"}}

    assert RequestParser.parse("GET /index.css HTTP/1.1") ==
             {:GET, "/index.css", %{"file" => "static/styles/index.css"}}
  end

  test "Parse query params to map" do
    assert RequestParser.parse_query("name=Eldar&pass=1234") == %{
             "name" => "Eldar",
             "pass" => "1234"
           }
  end
end
