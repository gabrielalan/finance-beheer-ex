defmodule FinanceServer.Http.Router do
	use Plug.Router

	plug Plug.Parsers, parsers: [:json], json_decoder: Poison
	plug :match
	plug :dispatch

	get "/", do: send_resp(conn, 200, "Welcome")

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

	match _, do: send_resp(conn, 404, "Oops!")
end
