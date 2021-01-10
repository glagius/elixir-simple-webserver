defmodule ResponseBuilderTest do
  use ExUnit.Case

  setup_all do
    home_page = "static/pages/home/index.html"
    about_page = "static/pages/about/index.html"
    not_found_page = "static/pages/404.html"

    values = %{
      home_page: File.read(home_page),
      about_page: File.read(about_page),
      not_found_page: File.read(not_found_page)
    }

    pages = %{
      home_page: home_page,
      about_page: about_page,
      not_found_page: not_found_page
    }

    {:ok, data: [pages, values]}
  end

  test "Resolve GET requests", state do
    [pages, values] = state.data
    {_, home} = Map.fetch(pages, :home_page)
    {_, about} = Map.fetch(pages, :about_page)
    {_, {_, home_html}} = Map.fetch(values, :home_page)
    {_, {_, about_html}} = Map.fetch(values, :about_page)
    {_, {_, not_found_html}} = Map.fetch(values, :not_found_page)
    root_params = %{"file" => home}
    about_params = %{"file" => about}
    not_found_params = %{"file" => "some/page.html"}
    assert ResponseBuilder.resolve({:GET, root_params}) == {:ok, home_html}
    assert ResponseBuilder.resolve({:GET, about_params}) == {:ok, about_html}

    assert ResponseBuilder.resolve({:GET, not_found_params}) ==
             {:error, {:enoent, not_found_html}}
  end

  # test "Resolve POST requests" do
  #   # some mocks for POST request
  #   assert ResponseBuilder.resolve({:POST, root_params}) == home_html
  #   assert ResponseBuilder.resolve({:POST, about_params}) == about_html
  #   assert ResponseBuilder.resolve({:POST, not_found_params}) == not_found_html
  # end
  test "Set headers for GET requests", state do
    [pages, values] = state.data
    {_, home} = Map.fetch(pages, :home_page)
    {_, about} = Map.fetch(pages, :about_page)
    {_, not_found} = Map.fetch(pages, :not_found_page)
    {_, {_, home_html}} = Map.fetch(values, :home_page)
    {_, {_, about_html}} = Map.fetch(values, :about_page)
    {_, {_, not_found_html}} = Map.fetch(values, :not_found_page)
    root_params = %{"file" => home}
    about_params = %{"file" => about}
    not_found_params = %{"file" => "some/page.html"}
    {_, home_html_size} = File.stat(home) |> (fn {_, stats} -> Map.fetch(stats, :size) end).()

    home_header =
      Enum.join(
        [
          "HTTP/1.1 200 OK",
          "Content-Type: text/html; charset=utf-8",
          "Content-Length: #{home_html_size}"
        ],
        "\n"
      )

    {_, about_html_size} = File.stat(about) |> (fn {_, stats} -> Map.fetch(stats, :size) end).()

    about_header =
      Enum.join(
        [
          "HTTP/1.1 200 OK",
          "Content-Type: text/html; charset=utf-8",
          "Content-Length: #{about_html_size}"
        ],
        "\n"
      )

    {_, not_found_html_size} =
      File.stat(not_found) |> (fn {_, stats} -> Map.fetch(stats, :size) end).()

    not_found_header =
      Enum.join(
        [
          "HTTP/1.1 404 NOT FOUND",
          "Content-Type: text/html; charset=utf-8",
          "Content-Length: #{not_found_html_size}"
        ],
        "\n"
      )

    assert ResponseBuilder.set_headers(root_params, {:ok, home_html}) == home_header
    assert ResponseBuilder.set_headers(about_params, {:ok, about_html}) == about_header

    assert ResponseBuilder.set_headers(not_found_params, {:error, {:enoent, not_found_html}}) ==
             not_found_header
  end
end
