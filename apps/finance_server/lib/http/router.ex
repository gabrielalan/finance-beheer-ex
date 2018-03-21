defmodule FinanceServer.Http.Router do
	use Plug.Router
	require Logger

	plug Plug.Parsers, parsers: [:json], json_decoder: Poison
	plug :match
	plug :dispatch

	get "/", do: send_resp(conn, 200, "Welcome")

	# TODO add tests
	post "/transactions" do
		list = Map.get(conn.body_params, "_json", [])

		Logger.info "Inserting transactions: #{inspect list}"

		case FinanceBeheer.insert_transactions(list) do
			{:error, reason} -> send_resp(conn, 500, reason)
			{:ok, result} -> send_resp(conn, 200, Poison.encode!(result))
		end
	end

	post "/hello" do
    {status, body} =
      case conn.body_params do
        %{"name" => name} -> {200, say_hello(name)}
        _ -> {422, missing_name()}
      end
    send_resp(conn, status, body)
  end

  defp say_hello(name) do
    Poison.encode!(%{response: "Hello, #{name}!"})
  end

  defp missing_name do
    Poison.encode!(%{error: "Expected a \"name\" key"})
  end

	match _ do 
		send_resp(conn, 404, "Oops!")
	end
end
