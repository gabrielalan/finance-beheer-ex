defmodule FinanceServer do
  use Application
  require Logger

  def start(_type, _args) do
    port = Application.get_env(:finance_server, :cowboy_port, 8001)
    children = [
      Plug.Adapters.Cowboy2.child_spec(scheme: :http, plug: FinanceServer.Http.Router, options: [port: port])
    ]

    Logger.info("Started application on #{port}")

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
