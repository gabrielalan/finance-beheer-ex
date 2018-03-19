defmodule FinanceServer.Http.RouterTest do
  use ExUnit.Case
  use Plug.Test

  alias FinanceServer.Http.Router

  @opts Router.init([])

  test "returns welcome" do
    conn =
      conn(:get, "/", "")
      |> Router.call(@opts)

    assert conn.state == :sent
		assert conn.status == 200
		assert conn.resp_body == "Welcome"
	end
	
	test "POST /hello with valid payload" do
    body = Poison.encode!(%{name: "Gaba"})

    conn = conn(:post, "/hello", body)
			|> put_req_header("content-type", "application/json")
			|> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert Poison.decode!(conn.resp_body) == %{"response" => "Hello, Gaba!"}
  end

  test "returns 404" do
    conn =
      conn(:get, "/missing", "")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 404
  end
end
