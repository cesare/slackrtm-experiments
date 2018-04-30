defmodule SlackRtm.Listener do
  def init(websocket) do
    loop(websocket)
  end

  def loop(websocket) do
    case Socket.Web.recv!(websocket) do
      {:ping, _} ->
        websocket |> Socket.Web.send!({:pong, ""})
      message ->
        IO.puts "**** got message: #{inspect message} ****"
    end

    loop(websocket)
  end
end
