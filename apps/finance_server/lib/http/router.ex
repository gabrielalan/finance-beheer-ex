defmodule FinanceServer.Http.Router do
	use Plug.Router
	require Logger

	plug Plug.Parsers, parsers: [:json], json_decoder: Poison
	plug FinanceBeheer.Plugs.Headers
	plug :match
	plug :dispatch

	# post "/hello" do
  #   {status, body} =
  #     case conn.body_params do
  #       %{"name" => name} -> {200, say_hello(name)}
  #       _ -> {422, missing_name()}
  #     end
  #   send_resp(conn, status, body)
  # end

	# TODO add tests
	post "/transactions" do
		list = Map.get(conn.body_params, "_json", [])

		Logger.info "Inserting transactions: #{inspect list}"

		case FinanceBeheer.insert_transactions(list) do
			{:error, reason} -> send_resp(conn, 422, reason)
			{:ok, result} -> send_resp(conn, 200, Poison.encode!(result))
		end
	end

	get "/transactions" do
		Logger.info "Retrieving all transactions"

		list = FinanceBeheer.get_all_transactions()
		send_resp(conn, 200, Poison.encode!(list))
	end

	get "/monthly-overview" do
		Logger.info "Retrieving monthly overview"
		send_resp(conn, 200, Poison.encode!(FinanceBeheer.get_monthly_overview()))
	end

	match _ do 
		send_resp(conn, 404, "Oops!")
	end
end
