defmodule FinanceServer.Http.RouterTest do
  use ExUnit.Case
  use Plug.Test

  alias FinanceServer.Http.Router

	@opts Router.init([])
	
	setup_all do
		Mongo.delete_many!(:mongo, "transactions", %{})
		:ok
	end

  test "POST /transactions with INVALID payload" do
    conn =
			conn(:post, "/transactions", "{}")
			|> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    assert conn.state == :sent
		assert conn.status == 422
		assert conn.resp_body == "Invalid data"
	end

  test "POST /transactions with VALID payload" do
    conn =
			conn(:post, "/transactions", "[{\"value\":123},{\"value\":321}]")
			|> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    assert conn.state == :sent
		assert conn.status == 200
		assert Enum.any? conn.resp_headers, fn {_, value} -> value == "application/json" end
		assert is_list(Poison.decode!(conn.resp_body)) == true
	end

  test "returns 404" do
    conn =
      conn(:get, "/missing", "")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 404
  end
end
