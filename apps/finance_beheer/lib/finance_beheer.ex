defmodule FinanceBeheer do
  alias BSON.ObjectId

  # {:ok,
  # %Mongo.InsertManyResult{
  #   inserted_ids: %{0 => #BSON.ObjectId<5ab2220d9737066fad32668a>}
  # }}
  def insert_transactions(transactions) when is_list(transactions) do
      with {:ok, result} <- Mongo.insert_many(:mongo, "transactions", transactions),
        inserted_ids <- Map.get(result, :inserted_ids, %{}),
        result <- Enum.map(inserted_ids, fn {_, id} -> ObjectId.encode!(id) end),
      do: {:ok, result}
  end

  def insert_transactions(_any) do
    {:error, :invalid_data}
  end

  def insert do
    Mongo.insert_many(:mongo, "lol", [%{first_name: "John", last_name: "Smith"}, %{first_name: "Jane", last_name: "Doe"}])
  end

  def find do
    Mongo.find(:mongo, "lol", %{})#, %{"$and" => [%{email: "my@email.com"}, %{first_name: "first_name"}]})
    |> Enum.map(&(&1["first_name"]))
  end
end
