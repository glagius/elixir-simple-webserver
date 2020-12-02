defmodule RequestHandlerTest do
  use ExUnit.Case
  doctest RequestHandler

  test "Must parse GET requests" do
    assert RequestHandler.parse("GET / HTTP/1.1") == {:GET, "/", %{}}
    assert RequestHandler.parse("GET /about HTTP/1.1") == {:GET, "/about", %{}}
    assert RequestHandler.parse("GET /api/v1/user HTTP/1.1") == {:GET, "/api/v1/user", %{}}

    assert RequestHandler.parse("GET /api/v1/user/23?name=Eldar&pass=1234 HTTP/1.1") ==
             {:GET, "/api/v1/user/23", %{"name" => "Eldar", "pass" => "1234"}}

    assert RequestHandler.parse("GET /styles.css HTTP/1.1") ==
             {:GET, "/", %{"file" => "styles.css"}}
  end

  test "Parse query params to map" do
    assert RequestHandler.parse_query("name=Eldar&pass=1234") == %{
             "name" => "Eldar",
             "pass" => "1234"
           }
  end
end
