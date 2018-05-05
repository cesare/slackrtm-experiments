defmodule SlackRtm.SqsListener do
  def init() do
    Application.get_env(:slack_rtm, :sqs_queue_name)
    |> loop
  end

  def loop(queue_name) do
    wait_for_message(queue_name) |> handle_response
    loop(queue_name)
  end

  def wait_for_message(queue_name) do
    ExAws.SQS.receive_message(queue_name, wait_time_seconds: 20)
    |> ExAws.request
  end

  def handle_response({:ok, %{body: body}}) do
    case body do
      %{messages: [message]} -> handle_message(message)
      %{messages: []} -> IO.puts "**** message empty ****"
    end
  end

  def handle_response(response) do
    IO.puts "**** unknown response #{inspect response} ****"
  end

  def handle_message(%{body: body_str}) do
    body = Poison.decode!(body_str)
    IO.puts "**** received message: #{inspect body} ****"
  end

  def handle_message(msg) do
    IO.puts "**** unknown message: #{inspect msg} ****"
  end
end
