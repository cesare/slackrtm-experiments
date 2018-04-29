defmodule SlackRtm.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, []) do
    import Supervisor.Spec, warn: false

    config = %SlackRtm.Config{
      token:    System.get_env("SLACK_TOKEN"),
      channel:  System.get_env("SLACK_CHANNEL"),
      bot_name: System.get_env("SLACK_BOT_NAME"),
    }

    # List all child processes to be supervised
    children = [
      worker(SlackRtm.Rtm, [config.token]),
      worker(SlackRtm.Channels, [config.token]),
      worker(SlackRtm.PostingBot, [config]),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SlackRtm.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
