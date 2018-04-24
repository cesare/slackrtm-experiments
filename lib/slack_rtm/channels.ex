defmodule SlackRtm.Channels do
  use GenServer

  def start_link(token) do
    GenServer.start_link(__MODULE__, token, name: __MODULE__)
  end

  def init(token) do
    {:ok, {token}}
  end

  def find_channel(channel_name) do
    case GenServer.call __MODULE__, :list_availale_channels do
      {:ok, channels} -> Enum.find(channels, fn %{"id" => id, "name" => name} -> name == channel_name end)
    end
  end

  def handle_call(:list_availale_channels, _from, {token}) do
    case list(token) do
      {:ok, channels} -> {:reply, {:ok, channels}, {token, channels}}
      {:error, e} -> {:reply, {:error, e}, {token}}
    end
  end

  def handle_call(:list_availale_channels, _from, {token, channels}) do
    {:reply, {:ok, channels}, {token, channels}}
  end

  def list(token) do
    query_string = URI.encode_query %{
      token: token,
      exclude_archived: true,
      exclude_members: true,
    }
    uri = "https://slack.com/api/channels.list?#{query_string}"
    response = HTTPoison.get uri
    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body |> Poison.decode! |> list_channels}
      _ -> {:error, "channels.list request failed"}
    end
  end

  def list_channels(%{"channels" => channels}) do
    Enum.map(channels, fn ch -> ch |> Map.take(["id", "name"]) end)
  end
end
