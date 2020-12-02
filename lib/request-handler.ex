defmodule RequestHandler do
  @moduledoc """
  Module will parse incoming requests, and call another functions.
  """

  @doc """
  Parse request string to METHOD, host, Headers, Query params

  ## Params

    - request - incoming request string

  ## Example


      iex> RequestHandler.parse("GET / HTTP/1.1")
      {:GET, "/", %{}}

      iex> RequestHandler.parse("GET /favicon.ico HTTP/1.1")
      {:GET, "/", %{ "file" => "favicon.ico" }}

      iex> RequestHandler.parse("GET /about HTTP/1.1")
      {:GET, "/about", %{}}


  """
  def parse(request) when is_binary(request) do
    String.split(request)
    |> parse_request
  end

  defp parse_request([method, host, _]) do
    method = String.to_atom(method)
    [path | query] = String.split(host, "?")
    params = parse_query(query)

    {method, path, params}
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
end
