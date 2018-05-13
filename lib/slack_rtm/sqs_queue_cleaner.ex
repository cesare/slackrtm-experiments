defmodule SlackRtm.SqsQueueCleaner do
  use GenServer

  def start_link(sqs_config) do
    GenServer.start_link(__MODULE__, sqs_config, name: __MODULE__)
  end

  def init(config) do
    {:ok, config}
  end

  def delete_message(receipt_handle) do
    GenServer.cast(__MODULE__, {:delete_message, receipt_handle})
  end

  def handle_cast({:delete_message, receipt_handle}, config) do
    config.queue_name |> ExAws.SQS.delete_message(receipt_handle) |> ExAws.request
    {:noreply, config}
  end
end
