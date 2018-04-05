defmodule FinanceBeheer do
  alias BSON.ObjectId

  # {:ok,
  # %Mongo.InsertManyResult{
  #   inserted_ids: %{0 => #BSON.ObjectId<5ab2220d9737066fad32668a>}
  # }}
  def insert_transactions(transactions) when is_list(transactions) and length(transactions) > 0 do
      with {:ok, result} <- Mongo.insert_many(:mongo, "transactions", transactions),
        inserted_ids <- Map.get(result, :inserted_ids, %{}),
        result <- Enum.map(inserted_ids, fn {_, id} -> ObjectId.encode!(id) end),
      do: {:ok, result}
  end

  def insert_transactions(_any) do
    {:error, "Invalid data"}
  end

  def get_all_transactions() do
    Mongo.find(:mongo, "transactions", %{})
    |> Enum.map(fn record ->
      id = Map.get(record, "_id")
      Map.replace!(record, "_id", ObjectId.encode!(id))
    end)
  end

  # def insert do
  #   Mongo.insert_many(:mongo, "lol", [%{first_name: "John", last_name: "Smith"}, %{first_name: "Jane", last_name: "Doe"}])
  # end

  # def find do
  #   Mongo.find(:mongo, "lol", %{})#, %{"$and" => [%{email: "my@email.com"}, %{first_name: "first_name"}]})
  #   |> Enum.map(&(&1["first_name"]))
  # end
end
