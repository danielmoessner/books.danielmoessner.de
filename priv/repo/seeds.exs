# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Books.Repo.insert!(%Books.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Books.{Repo, Library, Book}

library = Repo.insert!(%Library{})

books = [
  %{name: "Elixir in Action", author: "Sasa Juric", number: 1},
  %{name: "Programming Elixir", author: "Dave Thomas", number: 2},
  %{name: "Designing Elixir Systems with OTP", author: "James Edward Gray II", number: 3},
  %{name: "The Little Elixir & OTP Guidebook", author: "Benjamin Tan Wei Hao", number: 4},
  %{name: "Adopting Elixir", author: "Ben Marx", number: 5},
  %{name: "Phoenix in Action", author: "Geoffrey Lessel", number: 6},
  %{name: "Craft GraphQL APIs in Elixir with Absinthe", author: "Bruce Williams", number: 7},
  %{name: "Real-Time Phoenix", author: "Steve Bussey", number: 8},
  %{name: "Metaprogramming Elixir", author: "Chris McCord", number: 9},
  %{name: "Learn Functional Programming with Elixir", author: "Ulisses Almeida", number: 10}
]

for attrs <- books do
  Repo.insert!(%Book{library_id: library.id, name: attrs.name, author: attrs.author, number: attrs.number})
end
