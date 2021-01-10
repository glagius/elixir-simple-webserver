defmodule SimpleWebServerTest do
  use ExUnit.Case
  doctest SimpleWebServer

  # Write some tests e2e
  setup_all do
    home_page = "static/pages/home/index.html"
    about_page = "static/pages/about/index.html"
    not_found_page = "static/pages/404.html"

    values = %{
      root: File.read(home_page),
      about: File.read(about_page),
      not_found: File.read(not_found_page)
    }

    pages = %{
      root: home_page,
      about: about_page,
      not_found: not_found_page
    }

    {:ok, data: [pages, values]}
  end

  test("Resolve GET request for pages", state) do
    [pages, values] = state.data

    sizes =
      Enum.map(pages, fn {page, path} ->
        {
          page,
          File.stat(path)
          |> (fn {_, stats} ->
                {_, size} = Map.fetch(stats, :size)
                size
              end).()
        }
      end)
      |> Enum.into(%{})

    root_200 =
      Enum.join(
        [
          page_headers(:OK, :root, sizes),
          page_value(values[:root])
        ],
        "\n"
      )

    assert RequestParser.parse("GET / HTTP/1.1") |> ResponseBuilder.init() == root_200
  end

  def page_headers(:OK, page, sizes) do
    Enum.join(
      [
        "HTTP/1.1 200 OK",
        "Content-Type: text/html; charset=utf-8",
        "Content-Length: #{sizes[page]}"
      ],
      "\n"
    )
  end

  def page_value({_, data}), do: data
end
