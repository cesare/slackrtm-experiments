defmodule SlackRtm.Channels do
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
