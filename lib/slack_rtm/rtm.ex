defmodule SlackRtm.Rtm do
  use GenServer

  def start_link(token) do
    GenServer.start_link(__MODULE__, token, name: __MODULE__)
  end

  def init(token) do
    {:ok, ws} = connect!(token)
    spawn_link(SlackRtm.Listener, :init, [ws])
    {:ok, ws}
  end

  def send_message(message) do
    GenServer.cast(__MODULE__, {:send, message})
  end

  def handle_cast({:send, message}, websocket) do
    # websocket |> Socket.Web.send!({:text, message})
    {:noreply, websocket}
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
