defmodule FinanceBeheer.Application do
	use Application

	def start(_type, _args) do
		database = Application.get_env(:finance_beheer, :database)

    children = [
			# FinanceBeheer.Repo
			{Mongo, [name: :mongo, database: database]}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
