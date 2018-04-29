defmodule SlackRtm.PostingBot do
  use GenServer

  def start_link(token) do
    GenServer.start_link(__MODULE__, token, name: __MODULE__)
  end

  def init(token) do
    {:ok, {token}}
  end

  def post_message(text) do
    GenServer.cast(__MODULE__, {:send, text})
  end

  def handle_cast({:send, text}, {token}) do
    channel = System.get_env("SLACK_CHANNEL_ID")
    bot_name = System.get_env("SLACK_BOT_NAME")

    params = [
      {:token,    token},
      {:channel,  channel},
      {:text,     text},
      {:username, bot_name},
    ]
    uri = "https://slack.com/api/chat.postMessage"
    response = HTTPoison.post(uri, {:form, params})

    {:noreply, {token}}
  end
end
