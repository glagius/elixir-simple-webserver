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
    response =
      client
      |> read_line()
      |> RequestParser.parse()
      |> IO.inspect()
      |> ResponseBuilder.main()

    # |> IO.inspect()

    write_line(client, response)
  end

  defp read_line(client) do
    {:ok, request} = :gen_tcp.recv(client, 0)
    request
  end

  defp write_line(client, response) do
    :gen_tcp.send(client, response)
    :gen_tcp.close(client)
  end
end
