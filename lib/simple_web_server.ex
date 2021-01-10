defmodule SimpleWebServer do
  def main(port \\ 8080) do
    start(port)
  end

  def start(port) do
    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])

    loop(socket)
  end

  defp loop(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    # spawn Client module.
    spawn(__MODULE__, :receive_local, [client])
    loop(socket)
  end

  def receive_local(client) do
    client |> read_line |> IO.puts()
    write_line(client)
  end

  defp read_line(client) do
    {:ok, data} = :gen_tcp.recv(client, 0)
    # parse request url
    data
  end

  defp write_line(client) do
    {result, _} = :timer.tc(fn -> Process.sleep(5000) end)
    {_, index} = File.read("static/pages/home/index.html")
    :gen_tcp.send(client, "HTTP/1.1 200 OK
    Content-Type: text/html; charset=utf-8
    Content-Length: 1234

    #{index}")
    :gen_tcp.close(client)
  end
end
