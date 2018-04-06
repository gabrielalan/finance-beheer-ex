defmodule FinanceBeheer do
  alias BSON.ObjectId
  require Logger

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

  def get_monthly_overview() do
    Mongo.find(:mongo, "transactions", %{})
    |> group_by_operation()
    |> Stream.flat_map(&(&1))
    |> Enum.to_list
    |> format_monthly_overview()
  end

  def format_monthly_overview(grouped) do
    inbound = Enum.at(grouped, 0)
    outbound = Enum.at(grouped, 1)
    %{inbound: inbound, outbound: outbound}
  end

  def group_by_operation(transactions) do
    reducer = fn transaction, acc ->
      new_acc =
        case transaction["operation"] do
          "+" -> Map.replace! acc, :inbound, group_by_month(acc.inbound, transaction)
          "-" -> Map.replace! acc, :outbound, group_by_month(acc.outbound, transaction)
        end

      {:cont, new_acc}
    end

    after_fn = fn acc ->
      {:cont, [acc.inbound, acc.outbound], []}
    end

    Stream.chunk_while(
      transactions,
      %{inbound: %{}, outbound: %{}},
      reducer,
      after_fn
    )
  end

  def group_by_month(acc, transaction) do
    {:ok, date, 0} = DateTime.from_iso8601(transaction["date"])

    date = cond do
      date.day >= 22 -> Date.add(date, 10)
      true -> date
    end

    month = "#{date.year}-#{date.month}-01"
    value = transaction["value"]

    case Map.has_key?(acc, month) do
      true -> Map.update!(acc, month, &(&1 + value))
      false -> Map.put_new(acc, month, value)
    end
  end

  # [1,2,3] 
  # |> Stream.chunk_while(%{lol: 0, lel: 0}, fn(i, acc) -> {:cont, %{lol: acc.lol + i, lel: acc.lel - 1}} end, 
  #   fn acc -> {:cont, [acc.lol, acc.lel], []} end)
  # |> Stream.flat_map(&(&1))
  # |> Enum.to_list

  # def insert do
  #   Mongo.insert_many(:mongo, "lol", [%{first_name: "John", last_name: "Smith"}, %{first_name: "Jane", last_name: "Doe"}])
  # end

  # def find do
  #   Mongo.find(:mongo, "lol", %{})#, %{"$and" => [%{email: "my@email.com"}, %{first_name: "first_name"}]})
  #   |> Enum.map(&(&1["first_name"]))
  # end
end
