defmodule FinanceBeheer.Models.Transaction do
	@enforce_keys [:value, :operation]
	defstruct [:value, :operation]
	
	def is_transaction?(item) do
		match?(%FinanceBeheer.Models.Transaction{}, item)
	end
end
