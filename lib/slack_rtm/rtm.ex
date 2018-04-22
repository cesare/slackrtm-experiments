defmodule SlackRtm.Rtm do
  def start([token]) do
    {:ok, ws} = connect!(token)
    pid = spawn_link(fn -> loop(ws) end)
    Process.register pid, :websocket
    {:ok, pid}
  end

  def connect!(token) do
    case authenticate(token) do
      {:ok, %{"url" => url}} -> {:ok, url |> websocket_connect!}
      {:error, message} -> {:error, message}
    end
  end

  def authenticate(token) do
    query_string = URI.encode_query(%{token: token})
    uri = "https://slack.com/api/rtm.connect?#{query_string}"
    case HTTPoison.get(uri) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body |> Poison.decode!}
      _ -> {:error, "Authentication failed"}
    end
  end

  def websocket_connect!(uri) do
    Socket.connect!(uri)
  end

  def loop(websocket) do
    case Socket.Web.recv!(websocket) do
      {:ping, _} ->
        IO.puts "**** got ping ****"
        websocket |> Socket.Web.send!({:pong, ""})
      message ->
        IO.puts "**** got message: #{inspect message} ****"
    end

    loop(websocket)
  end
end
