defmodule FinanceBeheer do

  def insert do
    Mongo.insert_many(:mongo, "lol", [%{first_name: "John", last_name: "Smith"}, %{first_name: "Jane", last_name: "Doe"}])
  end

  def find do
    Mongo.find(:mongo, "lol", %{})#, %{"$and" => [%{email: "my@email.com"}, %{first_name: "first_name"}]})
    |> Enum.map(&(&1["first_name"]))
  end
end
