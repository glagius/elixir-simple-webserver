defmodule ResponseBuilder do
  @moduledoc """
  Module will read requested files, get data from database, set headers and combine into one string
  """

  def main({method, _path, params}) do
    # get data depends on method and params.
    # set headers depends on resolved data
    # return headers with result
    {status, value} = resolve({method, params})
    headers = set_headers(params, {status, value})
    Enum.join([headers, value], "\n") |> IO.inspect()
  end

  def resolve({:GET, params}) do
    case Map.fetch(params, "file") do
      {:ok, path} ->
        case Path.extname(path) do
          ".html" ->
            get_info({:html, path})

          ".css" ->
            get_info({:css, path})

          ".js" ->
            get_info({:js, path})

          ".jpg" ->
            get_info({:jpg, path})

          ".jpeg" ->
            get_info({:jpeg, path})

          ".ico" ->
            get_info({:ico, path})

          ".svg" ->
            get_info({:svg, path})

          _ ->
            get_info({:any, path})
        end

      _ ->
        IO.puts("JSON data requested = #{params}")
        # get_info(params)
    end
  end

  # def resolve({:POST, params}) do
  # end

  # def resolve({:PUT, params}) do
  # end

  # def resolve({:DELETE, params}) do
  # end

  # tODO: add error matching
  @spec get_info({atom, String.t()}) :: {:ok, String.t()} | {:error, {atom, String.t()}}
  def get_info({:html, path}) do
    file = File.read(path)
    not_found_address = "static/pages/404.html"
    {_, not_found_html} = File.read(not_found_address)

    case file do
      {:error, reason} -> {:error, {reason, not_found_html}}
      _ -> file
    end
  end

  # def get_info({:css, path}) do
  #   File.read(path)
  # end

  # def get_info({:js, path}) do
  #   File.read(path)
  # end
  def get_info({type, path}) do
    result = File.read(path)

    case result do
      {:error, _} ->
        result

      {:ok, value} ->
        case type do
          :jpg -> {:ok, Base.encode64(value)}
          :jpeg -> {:ok, Base.encode64(value)}
          :svg -> {:ok, Base.encode64(value)}
          :ico -> {:ok, Base.encode64(value)}
          _ -> result
        end
    end
  end

  @doc """
    Принимает на вход params, data где:
      params - requested data
      data - {:ok, string} / {:error, reason}

    Возвращает строку:
      HTTP/1.1 200 OK / HTTP/1.1 404 NOT FOUND
      Content-Type: text/html; charset=utf-8
      Content-Length: 1234
  """
  def set_headers(params, {status, value}) do
    Enum.join(
      [
        set_response_code({status, value}),
        set_content_type(params),
        set_content_length(params, {status, value})
      ],
      "\n"
    )
  end

  def set_content_type(params) do
    case Map.fetch(params, "file") do
      {:ok, path} ->
        case Path.extname(path) do
          ".html" -> "Content-Type: text/html; charset=utf-8"
          ".css" -> "Content-Type: text/css"
          ".js" -> "Content-Type: text/js"
          ".svg" -> "Content-Type: image/svg + xml"
          ".jpeg" -> "Content-Type: image/jpeg"
          ".jpg" -> "Content-Type: image/jpeg"
          ".ico" -> "Content-Type: image/x-icon"
        end

      _ ->
        "Content-Type: Application/json"
    end
  end

  def set_response_code({status, _value}) do
    case status do
      :ok ->
        "HTTP/1.1 200 OK"

      :error ->
        # TODO: Add Error handler module
        # "HTTP/1.1 #{code_by_reason(reason)} #{text_by_reason(reason)}"
        "HTTP/1.1 404 NOT FOUND"
    end
  end

  def set_content_length(_params, {status, value}) do
    # IO.puts(value)
    # TODO: Refactor this shit
    case status do
      :ok ->
        "Content-Length: #{String.length(value)}"

      # case Map.fetch(params, "file") do
      #   {:ok, path} ->
      #     "Content-Length: #{get_length(path)}"

      #   _ ->
      #     "Content-Length: #{String.length(value)}"
      # end

      :error ->
        {_reason, data} = value
        "Content-Length: #{String.length(data)}"
    end
  end

  def get_length(path) do
    {_, length} = File.stat(path) |> (fn {_, stats} -> Map.fetch(stats, :size) end).()
    length
  end

  def file_request?(params), do: Map.fetch(params, "file")
end
