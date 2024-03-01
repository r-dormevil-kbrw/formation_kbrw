defmodule FormationKbrw.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: FormationKbrw.Worker.start_link(arg)
      # {FormationKbrw.Worker, arg}
      {Server.Database, 0},
      {Plug.Cowboy, scheme: :http, plug: Server.Router, options: [port: 4001]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FormationKbrw.Supervisor]

    Logger.info("Starting application...")

    Supervisor.start_link(children, opts)
  end
end
