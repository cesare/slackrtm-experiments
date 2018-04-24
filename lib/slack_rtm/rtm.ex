defmodule SlackRtm.Rtm do
  use GenServer

  def start_link(token) do
    GenServer.start_link(__MODULE__, token, name: __MODULE__)
  end

  def init(token) do
    {:ok, identity, ws} = connect!(token)
    spawn_link(SlackRtm.Listener, :init, [ws])
    {:ok, {identity, ws, 1}}
  end

  def send_message(text) do
    GenServer.cast(__MODULE__, {:send, text})
  end

  def handle_cast({:send, text}, {identity, websocket, next_message_id}) do
    id = next_message_id
    channel = System.get_env("SLACK_CHANNEL_ID")
    message = %{
      "id" => id,
      "type" => "message",
      "channel" => channel,
      "text" => text,
    }
    json_message = Poison.encode!(message)
    websocket |> Socket.Web.send!({:text, json_message})
    {:noreply, {identity, websocket, id + 1}}
  end

  def connect!(token) do
    case authenticate(token) do
      {:ok, response = %{"url" => url}} ->
        {
          :ok,
          response["self"],
          url |> websocket_connect!
        }
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
