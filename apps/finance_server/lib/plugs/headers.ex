defmodule FinanceBeheer.Plugs.Headers do
	alias Plug.Conn

	@doc ~S"""
	Initialize the plug

	## Examples

			iex> FinanceBeheer.Plugs.Headers.init([])
			:ok

	"""
	def init(_opts) do
		:ok
	end

	def call(conn, _opts) do
		Conn.register_before_send conn, fn conn ->
			conn
			|> Conn.put_resp_header("content-type", "application/json")
		end
	end
end
