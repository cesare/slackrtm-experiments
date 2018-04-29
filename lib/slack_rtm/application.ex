defmodule SlackRtm.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, [token]) do
    import Supervisor.Spec, warn: false
    # List all child processes to be supervised
    children = [
      worker(SlackRtm.Rtm, [token]),
      worker(SlackRtm.Channels, [token]),
      worker(SlackRtm.PostingBot, [token]),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SlackRtm.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
