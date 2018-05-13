defmodule SlackRtm.SqsQueueCleaner do
  use GenServer

  def start_link(queue_name) do
    GenServer.start_link(__MODULE__, queue_name, name: __MODULE__)
  end

  def init(queue_name) do
    {:ok, queue_name}
  end

  def delete_message(receipt_handle) do
    GenServer.cast(__MODULE__, {:delete_message, receipt_handle})
  end

  def handle_cast({:delete_message, receipt_handle}, queue_name) do
    queue_name |> ExAws.SQS.delete_message(receipt_handle) |> ExAws.request
    {:noreply, queue_name}
  end
end
