defmodule RequestParser do
  @js "static/js"
  @static "static/styles"
  @pages "static/pages"
  @assets "static/assets"
  @moduledoc """
  Module will parse incoming requests, and return structure with METHOD, Request-path, Params.

  METHOD will be an atom, like :GET / :POST / :PATCH / :DELETE
  Request path - path to file or page from request
  Params - parsed query params, or path to requested file (page, assets and etc.) %{ key => value }

  """

  @doc """
  Parse request string to METHOD, host, Headers, Query params

  ## Params

    - request - incoming request string

  ## Example


      iex> RequestParser.parse("GET / HTTP/1.1")
      {:GET, "/", %{"file" => "static/pages/home/index.html"}}

      iex> RequestParser.parse("GET /favicon.ico HTTP/1.1")
      {:GET, "/favicon.ico", %{"file" => "static/assets/favicon.ico"}}

      iex> RequestParser.parse("GET /about HTTP/1.1")
      {:GET, "/about", %{"file" => "static/pages/about/index.html"}}


  """
  def parse(request) when is_binary(request) do
    String.split(request)
    |> parse_request
  end

  defp parse_request([method, host, _]) do
    req_method = String.to_atom(method)
    [path | query] = String.split(host, "?")
    file = parse_path(path)
    params = parse_query(query)

    {req_method, path, Map.put(params, "file", file)}
  end

  def parse_query([]), do: %{}

  def parse_query(person) when is_list(person) do
    List.foldl(person, %{}, fn q, acc -> parse_query(q) |> Map.merge(acc) end)
  end

  def parse_query(params) do
    String.split(params, "&")
    |> List.foldl(%{}, fn q, acc ->
      [key, value] = String.split(q, "=")
      Map.put_new(acc, key, value)
    end)
  end

  def get_page(path) do
    pathlist = Path.split(path)

    if length(pathlist) > 1 do
      Path.join([@pages, path, "index.html"])
    else
      Path.join([@pages, "home", "index.html"])
    end
  end

  defp parse_path(path) do
    case Path.extname(path) do
      ".css" -> Path.join(@static, path)
      ".js" -> Path.join(@js, path)
      ".ico" -> Path.join(@assets, path)
      _ -> get_page(path)
    end
  end
end
