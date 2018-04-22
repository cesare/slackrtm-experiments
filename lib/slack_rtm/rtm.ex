defmodule SlackRtm.Rtm do
  def connect! do
    case authenticate() do
      {:ok, %{"url" => url}} -> {:ok, URI.parse(url) |> websocket_connect!}
      {:error, message} -> {:error, message}
    end
  end

  def authenticate do
    case find_slack_token() do
      nil -> {:error, "Failed to find Slack token"}
      token -> authenticate(token)
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

  def find_slack_token do
    System.get_env("SLACK_TOKEN")
  end

  def websocket_connect!(uri) do
    Socket.Web.connect! uri.host, secure: true, path: uri.path
  end
end
