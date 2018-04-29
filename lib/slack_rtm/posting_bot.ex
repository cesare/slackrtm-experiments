defmodule SlackRtm.PostingBot do
  use GenServer

  def start_link(config) do
    GenServer.start_link(__MODULE__, config, name: __MODULE__)
  end

  def init(config) do
    {:ok, config}
  end

  def post_message(text) do
    GenServer.cast(__MODULE__, {:send, text})
  end

  def handle_cast({:send, text}, config) do
    params = [
      {:token,    config.token},
      {:channel,  config.channel},
      {:text,     text},
      {:username, config.bot_name},
    ]
    uri = "https://slack.com/api/chat.postMessage"
    response = HTTPoison.post(uri, {:form, params})

    {:noreply, config}
  end
end
