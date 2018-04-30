defmodule SlackRtm.Rtm do
  use GenServer

  def start_link(token) do
    GenServer.start_link(__MODULE__, token, name: __MODULE__)
  end

  def init(token) do
    {:ok, identity, ws} = connect!(token)
    spawn_link(SlackRtm.Listener, :init, [ws])
    {:ok, {identity, ws}}
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
        body |> Poison.decode
      _ -> {:error, "Authentication failed"}
    end
  end

  def websocket_connect!(uri) do
    Socket.connect!(uri)
  end
end
